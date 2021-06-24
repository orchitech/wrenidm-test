(function(){
    if (request.method !== "read") {
        throw {
            "code" : 403,
            "message" : "Access denied"
        };
    }

    return {
        hello: "world"
    };
})();
