package wrenidm;

import org.testcontainers.containers.wait.strategy.LogMessageWaitStrategy;

public class TomcatStartupWaitStrategy extends LogMessageWaitStrategy {
     public TomcatStartupWaitStrategy() {
        withRegEx(".*Wren:IDM ready.*");
        withTimes(1);
    }


}
