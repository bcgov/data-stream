var t = setInterval(runFunction, 1000);
var global_json = "";

function fetchAPI() {
  var targetUrl = (window.location.origin) ? window.location.origin + '/test_connection' : 'http://127.0.0.1:3000/test_connection';
  //var targetURL = 'http://localhost:3000/test_connection';
  fetch(targetUrl, {method: 'GET', mode: 'no-cors', headers: {Accept: 'application/json'}
    })
    .then(function(response){
      response = response.clone();
      console.log('Connected to Node server');
      response.json().then(data => {
          if(data.body!==undefined) {
              var body = JSON.parse(data.body);
              $('#connection_text').text("Connected to " + body.name);
              console.log(JSON.stringify(data));
              $('#response_text').text(" > " + JSON.stringify(data));
          } else {
              $('#connection_text').text("Failed to connect.");
              console.log(JSON.stringify(data));
              $('#response_text').text(" > " + JSON.stringify(data));
          }

      });
      //var json_response = (response.json());
      //console.log(json_response.body);
      //read body to determine connection.
      $('#connection_text').text("Connection successful.");
    })
    .catch(err => console.error('Caught error: ', err))
}

function selectDB(option_id) {
  $('.database_option').css("background-color", "white");
  $('#'+option_id).css("background-color", "#e9ecef");
  //function to fetch option info based on option-id
}

function runFunction() {
  var text = $('.moving').text();
  if(text==="Awaiting response..."){
    text="Awaiting response.";
  } else if(text==="Awaiting response.") {
    text = "Awaiting response..";
  } else  if(text==="Awaiting response..") {
    text = "Awaiting response...";
  }
  $('.moving').text(text);
}

function submit_choices() {
  confirm("Subscribe to databases?");
  var values = $('#db_choices').serialize();
  add_subscriptions(values);
  $('#db_choices').submit(function (e) {
    //code to send values
    e.preventDefault();
  });
}

//ONLY USE FOR DEMO
function refreshFile() {
  const local = false;
  if (!local) {
    $('#notify_button').hide();
    $('.notify_log').hide();
  }
  var refreshUrl = (window.location.origin) ? window.location.origin + '/on_load' : 'http://127.0.0.1:3000/on_load';
  //var refreshURL = 'http://localhost:3000/on_load';
  fetch(refreshUrl, {
    method: "GET",
    headers:{'Content-type': 'application/json',
      'User-agent': 'request'
    },
    json: true
  }).then(function (response) {
    response = response.clone();
    console.log('Success');
    response.json().then(data => {
      var currentSubString = "";
      for(var i = 0; i < data.length; i++) {
        if (data[i] !== '') {
          currentSubString = currentSubString + data[i] + "\n";
          $('#' + data[i]).attr({"disabled": true, "checked":false});
        }
      }
      $('.info_text').text(currentSubString);
      console.log(currentSubString);
    });
    console.log('ready for subscriptions');
  }).catch(function (error) {
    console.log(error);
  });
}

function get_subscriptions() {
  if (global_json === "") {
    var data = "No subscriptions.";
    $('.info_text').text(data);

    // fs.writeFile('../temp_files/subs.txt',data, (err) => {
    //   if (err) console.log(err);
    //   console.log("Successfully Written to File.")
    // })
  } else {
    $('.info_text').text(global_json)
  }
}

function add_subscriptions(values) {
  //var string_values = values.toString();
  var string_values = values.replace("%20", " ");
  var value_split = string_values.split(/[, =&]+/);
  console.log("Values:");
  console.log(value_split);
  for(var i = value_split.length-1; i>=0; i--){
    if(value_split[i] === 'on') {
      value_split[i] = '0';
    }
  }

  var sub_array = clean_form_values(value_split);
  console.log(sub_array);
  var subscribeUrl = (window.location.origin) ? window.location.origin + '/subscribe' : 'http://127.0.0.1:3000/subscribe';
  //var subscribe_url = 'http://localhost:3000/subscribe';
  fetch(subscribeUrl, {
    method: "POST",
    body: JSON.stringify(sub_array),
    headers:{'Content-type': 'application/json',
             'User-agent': 'request'
    },
    json: true
  })
      .then(function (response) {
        response = response.clone();
        console.log('Success');
        response.json().then(data => {
          $('#response_text').text(" > " + JSON.stringify(data));
          });
        updateSubscriptions(sub_array);
      })
      .catch(function(error){
        console.log(error);
      });

}

function clean_form_values(value_split) {
  var sub_array = [];
  var temp_string = "";
  for(var j = 0; j<value_split.length; j++) {
    if(value_split[j] === '0') {
      temp_string = temp_string.substring(0, temp_string.length-1);
      sub_array.push(temp_string);
      temp_string="";
    } else {
      if(temp_string==="") {
        temp_string=value_split[j] + " ";
      } else {
        temp_string = temp_string + value_split[j] + " ";
      }
      temp_string = temp_string.replace("%2F", "/");
    }
  }
  return sub_array;
}

function updateSubscriptions(sub_array) {
  var writeUrl = (window.location.origin) ? window.location.origin + '/write_file' : 'http://127.0.0.1:3000/write_file';
  //var writeUrl = 'http://localhost:3000/write_file';
  fetch(writeUrl, {
    method: "POST",
    body: JSON.stringify(sub_array),
    headers:{'Content-type': 'application/json',
      'User-agent': 'request'
    },
    json: true
  }).then(function (response) {
    response = response.clone();
    response.json().then(data => {
      var display_sub_text = "";
      for(var i = 0; i < data.length; i++) {
        console.log("Disabling: " + data);
        if (i !== data.length - 1 || data[i]!=='') {
          $('#' + data[i]).attr({"disabled": true, "checked":false});
          display_sub_text = display_sub_text + data[i] + "\n";
        } else if (data[i]!=='') {
          $('#' + data[i]).attr({"disabled": true, "checked":false});
          display_sub_text = display_sub_text + data[i] + "\n";
        }
      }
      console.log(display_sub_text);
      $('.info_text').text(display_sub_text);
    });
  });

}

function postNotification(notification) {
  console.log("Notification!");
  console.log(json.stringify(notification));
  $('#response_text').text(JSON.stringify(notification));
}

function test_Notification() {
  $('#notify_text').text("Loading...");
  var testUrl = (window.location.origin) ? window.location.origin + '/test_notify' : 'http://127.0.0.1:3000/test_notify';
  //var testurl = 'http://localhost:3000/test_notify';
  fetch(testUrl, {
    method: "GET",
    mode: 'no-cors',
    headers:{'Content-type': 'application/json',
      'User-agent': 'request'
    },
    json: true
  }).then(function (response) {

  }).catch(function (error) {
    console.log(error);
  });
}






