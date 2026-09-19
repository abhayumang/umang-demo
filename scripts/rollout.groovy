// Shared rollout logic. Jenkinsfile.rollout aur Jenkinsfile.scheduler isko `load` karte hain.
// Yeh file node{} ke andar se load hoti hai, isliye sh/stage/parallel/lock direct chalte hain.

@NonCPS
def windowOpen(String window, String now) {
    if (!window) { return true }
    def p = window.split('-')
    return now >= p[0].trim() && now <= p[1].trim()
}

// Ek wave ke departments ko "window khula" / "window band" me baantta hai
@NonCPS
def splitByWindow(Map m, String wave, String now) {
    def openNow = []
    def closed = []
    for (d in m.departments) {
        if (d.wave == wave) {
            if (windowOpen(d.window as String, now)) {
                openNow << (d.id as String)
            } else {
                closed << (d.id as String)
            }
        }
    }
    return [open: openNow, closed: closed]
}

// List ko batch_size ke tukdon me todta hai
@NonCPS
def chunk(List items, int size) {
    def out = []
    def cur = []
    for (x in items) {
        cur << x
        if (cur.size() == size) {
            out << cur
            cur = []
        }
    }
    if (cur) { out << cur }
    return out
}

// Ek batch ke saare departments PARALLEL me deploy. Har department par lock,
// fail hone par us department ko purane version par rollback, phir error (rollout ruk jata hai).
def deployBatch(List batch, String version) {
    def branches = [:]
    for (int i = 0; i < batch.size(); i++) {
        def dept = batch[i] as String
        branches[dept] = {
            lock(resource: 'dept-lock-' + dept) {
                def prev = sh(script: "bash scripts/current_version.sh ${dept}", returnStdout: true).trim()
                def rc = sh(script: "bash scripts/deploy_dept.sh ${dept} ${version}", returnStatus: true)
                if (rc != 0) {
                    if (prev && prev != version) {
                        echo "[${dept}] FAILED -> rollback to ${prev}"
                        sh "bash scripts/deploy_dept.sh ${dept} ${prev}"
                    }
                    error "Deploy failed on ${dept}"
                }
            }
        }
    }
    parallel branches
}

// Waves ke hisaab se rollout: canary -> wave1 -> wave2 (har wave batches me, waves ke beech approval)
def runRollout(Map m, String version, int batchSize, boolean autoPromote) {
    def now = sh(script: 'date +%H:%M', returnStdout: true).trim()
    echo "Rollout ${version} | abhi ka time ${now} | batch size ${batchSize}"

    def waves = m.waves
    for (int w = 0; w < waves.size(); w++) {
        def wave = waves[w] as String
        def parts = splitByWindow(m, wave, now)
        def openNow = parts.open
        def closed = parts.closed

        if (closed) {
            echo "Wave ${wave}: window band hai, skip -> ${closed} (scheduler window khulne par deploy karega)"
        }
        if (!openNow) {
            continue
        }

        stage("Wave: ${wave}") {
            def batches = chunk(openNow, batchSize)
            for (int b = 0; b < batches.size(); b++) {
                echo "Batch ${b + 1}/${batches.size()}: ${batches[b]}"
                deployBatch(batches[b], version)
            }
        }

        if (w < waves.size() - 1 && !autoPromote) {
            timeout(time: 30, unit: 'MINUTES') {
                input message: "Wave '${wave}' theek chali. Agli wave deploy karein?", ok: 'Promote'
            }
        }
    }

    stage('Approve release') {
        sh "bash scripts/state.sh set approved.version ${version}"
        echo "Version ${version} approved (scheduler ab baaki departments par window ke hisaab se deploy karega)"
    }
}

// Scheduler: jo departments approved version se peeche hain aur jinki window abhi khuli hai, unhe deploy karo
def catchUp(Map m, String version, int batchSize) {
    def now = sh(script: 'date +%H:%M', returnStdout: true).trim()
    def due = []
    for (int i = 0; i < m.departments.size(); i++) {
        def d = m.departments[i]
        if (windowOpen(d.window as String, now)) {
            def cur = sh(script: "bash scripts/current_version.sh ${d.id}", returnStdout: true).trim()
            if (cur != version) {
                due << (d.id as String)
            }
        }
    }
    echo "Approved ${version} | time ${now} | deploy due: ${due}"
    if (!due) {
        return
    }
    def batches = chunk(due, batchSize)
    for (int b = 0; b < batches.size(); b++) {
        stage("Catch-up batch ${b + 1}") {
            deployBatch(batches[b], version)
        }
    }
}

return this
