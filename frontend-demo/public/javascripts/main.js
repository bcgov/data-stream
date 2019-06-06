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
              $('#response_text').append(" > " + JSON.stringify(data) + "\n");
          } else {
              $('#connection_text').text("Failed to connect.");
              console.log(JSON.stringify(data));
              $('#response_text').append(" > " + JSON.stringify(data) + "\n");
          }

      });
      //var json_response = (response.json());
      //console.log(json_response.body);
      //read body to determine connection.
      $('#connection_text').text("Connection successful.");
    })
    .catch(err => console.error('Caught error: ', err))
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

function sub_choices() {
  if (confirm("Subscribe to databases?")) {
    var values = $('#db_choices').serialize();
    add_subscriptions(values);
    $('#db_choices').submit(function (e) {
      e.preventDefault();
    });
  }
}

function unsub_choices() {
  if (confirm("Unsubscribe to databases?")) {
    var values = $('.unsub_box');
    var client_unsub_array = [];
    var flask_unsub_array = [];
    var len = values.length;
    for(var i = 0; i < len; i++) {
      if (values[i].checked) {
        var trimmed = values[i].id.replace("_subbed", '');
        flask_unsub_array.push(trimmed);
      } else {
        var trimmed = values[i].id.replace("_subbed", '');
        client_unsub_array.push(trimmed);
      }
    }
    if (flask_unsub_array.length===0) {
      console.log("Nothing to unsub");

    }

    remove_subscriptions(client_unsub_array, flask_unsub_array);
    $('#unsub_choices').submit(function (e) {
      e.preventDefault();
    });
  }
}

function remove_subscriptions(client_unsub_array, flask_unsub_array) {
  var post_dict = {
    "client_unsub_array": client_unsub_array,
    "flask_unsub_array": flask_unsub_array
  };

  var unsubUrl = (window.location.origin) ? window.location.origin + '/unsubscribe' : 'http://127.0.0.1:3000/unsubscribe';
  //var unsubUrl = 'http://localhost:3000/unsubscribe';
  fetch(unsubUrl, {
    method: "POST",
    body: JSON.stringify(post_dict),
    headers:{'Content-type': 'application/json',
      'User-agent': 'request'
    },
    json: true
  }).then(function (response) {
    response = response.clone();
    response.json().then(data => {
      var display_sub_text = "";
      for (var i = 0; i < client_unsub_array.length; i++) {
        if (client_unsub_array[i] !== '') {
          //update_sub(client_unsub_array[i]);
          disableSub(client_unsub_array[i]);
        }
      }
      for (var i = 0; i < flask_unsub_array.length; i++) {
        force_remove(flask_unsub_array[i] + "_subbed");
        enableDb(flask_unsub_array[i]);
      }
      $('#response_text').append(" > Deletion success! " + data + "\n");
    });
  });
}

function enableAll() {
  var toEnable = $('.sub_database_option');
  for (var i = 0; i <toEnable.length; i++) {
    var element = toEnable[i];
    element.attr({"disabled" : false});
    element.prop({"checked" : false});
  }
}

function enableDb(Db) {
  var theDb = $('#' + Db);
  theDb.attr({"disabled" : false});
  theDb.prop({"checked" : false});
}

function force_remove(sub) {
  $('#' + sub).remove();
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
    response.json().then(data => {
      for(var i = 0; i < data.length; i++) {
        if (data[i] !== '') {
          update_sub(data[i]);
          disableSub(data[i]);
        }
      }
      var container = $('#current_sub_container');
      console.log((container.height()));
      container.height(150);
      container.css("overflow-y", "scroll");
    });
    console.log('ready for subscriptions');
  }).catch(function (error) {
    console.log(error);
  });
}

function disableSub(sub_id) {
  $('#' + sub_id).attr({"disabled": true, "checked":false});
}

function update_sub(sub_id) {
  var newDiv = document.createElement("div");
  newDiv.className = "unsub_database_option border-bottom";
  newDiv.id = sub_id + "_subbed";
  var container = $('#current_sub_container');
  $('<input />', { type: 'checkbox', id: sub_id + "_subbed", class: "unsub_box", value: sub_id + "_subbed" }).appendTo(newDiv);
  $('<label />', { 'for': sub_id + "_subbed", text: sub_id }).appendTo(newDiv);
  $('<br />').appendTo(newDiv);
  container.append(newDiv);
  var theDb = $('#' + sub_id);
  theDb.attr({"disabled" : false});
  theDb.prop({"checked" : false});
  //$('#' + sub_id).attr({"disabled": false, "checked":false, "margin-left":"10px"});
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
          $('#response_text').append(" > " + JSON.stringify(data) + "\n");
          });
        postSubscriptions(sub_array);
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

function postSubscriptions(sub_array) {
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
      for(var i = 0; i < sub_array.length; i++) {
        if(sub_array[i]!== ''){
          enableAll();
          update_sub(sub_array[i]);
          disableSub(sub_array[i]);
        }
      }
    });
  });

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






