var express = require('express');
var router = express.Router();

//Create json file with the subscribed data sets, return the text of the created json file.
router.post('/', function(req, res, next) {
    var fs = require('fs');
    var sub_array = req.body;
    var file_contents = "";

    fs.readFile('./temp_files/temp.txt', 'utf-8', function (err, data) {
        if(err) throw err;
        var split_data = data.split("\n");
        var input= "";
        for(var i = 0; i < sub_array.length; i++) {
            if(split_data.includes(sub_array[i])) {
                continue;
            } else {
                input = input + sub_array[i] + "\n";
            }
        }
        if(input!==""){
            fs.writeFile('./temp_files/temp.txt', input, {flag: 'a+'}, function (error, data) {
                if(error) throw error;
                fs.readFile('./temp_files/temp.txt', 'utf-8', function (err, data) {
                    var split_data_2 = data.split("\n");
                    console.log('new subs');
                    res.json(split_data_2);

                });
            });

        } else {
            console.log('no new subs');
            res.json(split_data);
        }

    });


    // fs.readFile('./temp_files/temp.txt', 'utf8', function(error, contents) {
    //     console.log(contents);
    //
    // });

    //the_subscribed = file_contents.split(/[/n, ]+/);


});

module.exports = router;