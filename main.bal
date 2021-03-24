import ballerina/http;
import ballerinax/mysql;
import ballerina/sql;
import ballerina/log;
import ballerina/io;

configurable string username  = ?;
configurable string password  = ?;


listener http:Listener ticketBooking = new(9090);
mysql:Client mysqlClient = check new (user = username, password = password);

string name = "";
string seatNum = "";
boolean paymentDone = false;

service /movies on ticketBooking {

    // resource function get movies() returns stream<record{|anydata...;|}, error> {
    //     stream<record{|anydata...;|}, error> res = mysqlClient->query("SELECT * FROM ticket_booking.Movie");
    //     log:printDebug(res.toString());
    //     return res;
    // }

    resource function get movies() returns string|error {
        boolean validation = false;
        string[] movieNames = [];
        stream<record{|anydata...;|}, error> res = mysqlClient->query("SELECT * FROM ticket_booking.Movie");
        log:printInfo(res.toString());

        error? e = res.forEach(function(record {} result) {
        io:print("Serial No: ", result["id"]);
        io:println(" Movie: ", result["name"]);
        movieNames.push(<string>result["name"]);
        });

        if (e is error) {
            log:printError("Error occurred while retriving data!");
        }

        string movieName = io:readln(string `Enter the movie name : `);
        foreach string val in movieNames {
        if (val.equalsIgnoreCaseAscii(movieName)) {
            validation = true;
        }

        }
        if (!validation) {
            log:printError("Invalid movie name");
            return error error:Retriable("Invalid movie name");
        } else {
            return name;
        }
    }

    resource function post createTable() returns sql:Error? {
        sql:ExecutionResult result = check mysqlClient->execute("CREATE TABLE IF NOT EXISTS Movie " + 
            "(name VARCHAR(300), PRIMARY KEY(name))");
        result = check mysqlClient->execute("INSERT INTO Movie(name) VALUES ('TENET')");
    }


}

service /seatAllocation on ticketBooking {

    resource function get seatNumber() returns string|error {
        boolean validation = true;
        string[] seats = [];
        stream<record{|anydata...;|}, error> res = mysqlClient->query("SELECT * FROM ticket_booking.Seat");
        log:printInfo(res.toString());

        io:println("Available seats: ");
        error? e = res.forEach(function(record {} result) {
        io:println(result["seatNum"]);
        seats.push(<string>result["seatNum"]);
        });

        if (e is error) {
            log:printError("Error occurred while retriving data!");
        }

        string seat = io:readln(string `Enter an available seat No : `);
        foreach string val in seats {
        if (val.equalsIgnoreCaseAscii(seat)) {
            validation = false;
        }

        }
        if (!validation) {
            log:printError("Invalid seat number");
            return error error:Retriable("Invalid seat selection");
        } else {
            return seatNum;
        }
    }

    resource function post reserveSeat(http:Request req) returns sql:Error? {
        json|error token = req.getJsonPayload();
        if(token is json) {
            json|error name = token.name;
            json|error seatNum = token.seatNum;
            if(name is json && seatNum is json){
                string val = name.toString();
                string seatNumber = seatNum.toString();

                sql:ParameterizedQuery query = `INSERT INTO Seat (seatNo, name) VALUES (${seatNumber}, ${val})`;
                sql:ExecutionResult result = check mysqlClient->execute(query);
                io:println("Booking Confirmed: ", result);
            }
        } else {
            return <sql:Error>token;
        }
    }


}

service /doPayment on ticketBooking {

}

public function main() {
    
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





