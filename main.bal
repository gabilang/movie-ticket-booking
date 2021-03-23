import ballerina/http;
import ballerinax/mysql;
// import ballerina/sql;
import ballerina/log;

configurable string username  = ?;
configurable string password  = ?;

type Movie record {|
    int id;
    string name;
|};


listener http:Listener ticketBooking = new(9090);
mysql:Client mysqlClient = check new (user = username, password = password);

service / movies on ticketBooking {

    resource function get movies() returns stream<record{|anydata...;|}, error> {
        stream<record{|anydata...;|}, error> res = mysqlClient->query("Select * from ticket_booking.Movie");
        log:printDebug(res.toString());
        return res;
    }

    // resource function post selectMovie() returns sql:Error? {
    //     string name = 
    // }
}

service / seatAllocation on ticketBooking {

}

service / transactionSomething on ticketBooking {

}


// http:Client backendClient = check new("http://localhost:9092");

// service /call on new http:Listener(9090) {

//     resource function get availableMovies() returns http:Response {
//         var result = backendClient -> get("/backend/String", targetType = string);

//         if (result is ClientError) {
//             log:printError("Error: " + result.message());
//             return result;
//         } else {

//             log:printInfo("String payload: " + result);
//         }
//     }

// }

// service /backend on new http:Listener(9092) {

//     resource function get 'String() returns string {
//         return "something";
//     }
// }





