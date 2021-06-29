(function() {
    console.log("filter here. Don't you dare sending param=bar");
    console.log("val " + !(request.additionalParameters.hasOwnProperty("param") && request.additionalParameters["param"] === "bar"));
    if (request.additionalParameters.hasOwnProperty("param") && request.additionalParameters["param"] === "bar") {
        throw {
            "code" : 403,
            "message" : "I told you not to send it!",
            "detail" : "You sent param=bar"
        };
    };
})();

