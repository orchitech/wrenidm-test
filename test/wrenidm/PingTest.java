package wrenidm;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestInstance;
import org.junit.jupiter.api.TestInstance.Lifecycle;
import org.testcontainers.containers.ComposeContainer;

import java.io.File;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

@TestInstance(Lifecycle.PER_CLASS)
public class PingTest extends BaseWrenIdmTest {

    @SuppressWarnings("resource")
    @BeforeAll
    public void init() {
        environment = new ComposeContainer(new File("test/wrenidm/ping/compose.yaml")).withLocalCompose(true);
        environment.waitingFor(WRENIDM_CONTAINER_NAME, new TomcatStartupWaitStrategy());
        environment.start();
    }

    @AfterAll
    public void teardown() {
        if (environment != null) {
            environment.stop();
        }
    }

        private static final String ADMIN_USERNAME = System.getenv("ADMIN_USERNAME");
        private static final String ADMIN_PASSWORD = System.getenv("ADMIN_PASSWORD");
        private final ObjectMapper mapper = new ObjectMapper();

    @Test
    void testPingResponse() throws Exception {
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create("http://wrenidm.wrensecurity.local:8080/openidm/info/ping"))
                .header("X-OpenIDM-Username", ADMIN_USERNAME)
                .header("X-OpenIDM-Password", ADMIN_PASSWORD)
                .build();
        HttpResponse<String> response = HttpClient.newHttpClient().send(request, HttpResponse.BodyHandlers.ofString());
        assertEquals(200, response.statusCode());
        Map<String, String> responseBody = mapper.readValue(response.body(), new TypeReference<Map<String, String>>() {});
        assertEquals("ACTIVE_READY", responseBody.get("state"));
    }
}
