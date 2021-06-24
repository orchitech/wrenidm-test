/* global openidm, logger */



var counter = {
    value: '0'
};


var result = openidm.query('managed/counter', {
    "_queryFilter": '_id eq "counter1"'
});
var counter = null;
if (!result.result.length) {
    counter = openidm.create('managed/counter', 'counter1', {
        value: '0'
    });
} else {
    counter = result.result[0];
}
var newValue = (parseInt(counter.value) + 1).toString();
counter.value = newValue;
openidm.update('managed/counter/counter1', counter._rev, counter);
java.lang.System.out.println('Scheduler is working: ' + counter.value);