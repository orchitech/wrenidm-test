FROM openjdk:11
COPY ./h2-*.jar /h2/h2.jar
COPY openidm.sql /h2/openidm.sql
ENTRYPOINT [ "java", "-jar", "/h2/h2.jar"]