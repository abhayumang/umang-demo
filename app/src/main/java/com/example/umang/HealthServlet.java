package com.example.umang;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/** Dummy department app: /umang/health department ka naam aur version dikhata hai. */
@WebServlet("/health")
public class HealthServlet extends HttpServlet {

    private final Properties props = new Properties();

    @Override
    public void init() throws ServletException {
        try (InputStream in = getClass().getResourceAsStream("/app.properties")) {
            if (in != null) {
                props.load(in);
            }
        } catch (IOException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String dept = System.getenv().getOrDefault("DEPT_NAME", "unknown");
        String version = props.getProperty("app.version", "unknown");
        boolean fail = Boolean.parseBoolean(props.getProperty("health.fail", "false"));

        resp.setContentType("application/json");
        resp.setStatus(fail ? 500 : 200);
        resp.getWriter().write("{\"dept\":\"" + dept + "\",\"version\":\"" + version
                + "\",\"status\":\"" + (fail ? "DOWN" : "UP") + "\"}");
    }
}
