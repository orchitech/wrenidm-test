package wrenidm;

import org.testcontainers.containers.ComposeContainer;
import java.net.http.HttpClient;

public class BaseWrenIdmTest {

    protected static final String WRENIDM_CONTAINER_NAME = "wrenidm";

    protected final HttpClient httpClient = HttpClient.newHttpClient();

    protected ComposeContainer environment;
    
}
