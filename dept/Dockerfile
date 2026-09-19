FROM tomcat:9.0-jdk17-temurin

# Tomcat manager enable (deploy ke liye) - sirf demo/local use ke liye
RUN cp -r /usr/local/tomcat/webapps.dist/manager /usr/local/tomcat/webapps/manager
COPY manager-context.xml /usr/local/tomcat/webapps/manager/META-INF/context.xml
COPY tomcat-users.xml /usr/local/tomcat/conf/tomcat-users.xml

ENV JAVA_OPTS="-Xms64m -Xmx160m"
