# Umang multi-department rollout (local demo)

Local demo: **Docker Desktop + MinIO (S3 ki jagah) + Jenkins + GitHub**.
6 dummy departments (Tomcat containers) par ek WAR waves aur batches me deploy hota hai.

```
git push -> Jenkins build (WAR) -> MinIO (versioned) -> rollout job -> canary -> approval -> wave1 -> wave2
                                                                          (har wave batches me, parallel)
                                     scheduler job -> jin departments ki window baad me khulegi unhe catch-up deploy
```

## Kya kya hai
| Cheez | Kaam |
|---|---|
| `docker-compose.yml` | Jenkins + dept-01..dept-06 (Tomcat) |
| `Jenkinsfile` | Job `umang-build`: WAR build, MinIO me publish, rollout trigger |
| `Jenkinsfile.rollout` | Job `umang-rollout`: canary/waves/batches, approval, rollback |
| `Jenkinsfile.scheduler` | Job `umang-scheduler`: window ke hisaab se alag-alag time par deploy |
| `manifest/departments.yaml` | Department, wave aur maintenance window |
| `scripts/` | deploy, publish, status aur shared rollout logic |
| `app/` | Dummy WAR, `/umang/health` department ka naam + version dikhata hai |

## Setup (ek baar)
1. GitHub par naya repo banaiye aur ye poora folder push kijiye (branch `main`).
2. `cp .env.example .env` aur usme apne MinIO ke access key / secret key daaliye.
3. `docker compose up -d --build` (pehli baar 5-10 minute lagenge).
4. Apne MinIO container ko is network se jodiye (naam `docker ps` se dekhiye):
   `docker network connect --alias minio umang-net <minio-container-name>`
   Check: `docker exec umang-jenkins curl -s -o /dev/null -w "%{http_code}" http://minio:9000/minio/health/live` -> `200`
5. Jenkins kholiye: http://localhost:8080
   Password: `docker exec umang-jenkins cat /var/jenkins_home/secrets/initialAdminPassword`
   Manage Jenkins -> Nodes -> Built-In Node -> Number of executors = 4
6. Teen Pipeline jobs banaiye (New Item -> Pipeline -> "Pipeline script from SCM" -> Git -> repo URL, branch `*/main`).
   Naam bilkul yehi rakhiye:
   - `umang-rollout`   Script Path: `Jenkinsfile.rollout`   -> **Build Now ek baar** (VERSION khali hone se fail hoga, ye theek hai; isse parameters register hote hain)
   - `umang-scheduler` Script Path: `Jenkinsfile.scheduler` -> **Build Now ek baar** (cron register hota hai)
   - `umang-build`     Script Path: `Jenkinsfile`           -> Build Now
   (Private repo ho to Jenkins Credentials me GitHub token banakar job me select kijiye.)
7. `umang-build` ke baad `umang-rollout` khud chalega. Canary (dept-01) ke baad "Promote" par click karke agli wave chalaiye.
8. Kaun sa department kis version par hai: `bash scripts/status.sh` (laptop par; Windows me Git Bash/WSL)

## Demo flow
1. `manifest/departments.yaml` dikhaiye (waves, windows).
2. `app/src/main/resources/app.properties` ya kisi file me chhota change, push. 1 minute me Jenkins build uthayega.
3. Canary: sirf dept-01 naye version par. `status.sh` se dikhaiye.
4. Promote dijiye: wave1 (dept-02, dept-03) parallel batch me.
5. Promote: wave2. dept-06 skip hoga kyunki window band hai, scheduler window khulne par deploy karega.
   (Demo se pehle dept-06 ki window ko "abhi ka time + 5 minute" par set kar dijiye.)
6. Failure demo: `health.fail=true` karke push. Canary fail hoga, dept-01 purane version par rollback hoga, baaki departments touch nahi honge. Phir `false` karke push.

## Dikkat aaye to
- `bad interpreter` / `^M` error: Windows line endings. `git add --renormalize .` phir commit.
- Jenkins ko MinIO nahi mil raha: step 4 dobara dekhiye (network + alias `minio`).
- Manager 401/403: `.env` ka TOMCAT_USER/PASSWORD aur `dept/tomcat-users.xml` match hone chahiye.
- "Scripts not permitted to use method ...": Manage Jenkins -> In-process Script Approval -> Approve.
- Ports 8080-8086 busy hon to `docker-compose.yml` me ports badaliye.
- Docker Desktop ko kam se kam 4 GB RAM dijiye.

## AWS par jaate waqt kya badlega
| Local | AWS |
|---|---|
| MinIO (`aws s3 --endpoint-url`) | S3: `MINIO_ENDPOINT` khali karo, scripts wahi rahenge (versioning on) |
| Tomcat manager se deploy | SSM Run Command ya CodeDeploy |
| Dept containers | Department EC2 / ASG (tags se target) |
| pollSCM | GitHub webhook |
| `umang-net` | VPC + security groups |
| scheduler + `approved.version` | Maintenance windows / EventBridge Scheduler |
