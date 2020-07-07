package main

import (
	"fmt"
	"log"

	env "github.com/Netflix/go-env"
	// "github.com/aws/aws-lambda-go/events"
	// "github.com/aws/aws-lambda-go/lambda"
	fauna "github.com/fauna/faunadb-go/faunadb"
)

type environment struct {
	FaunaSecret string `env:"FAUNADB_SECRET"`
}

type token struct {
	FaunaToken string `fauna:"secret"`
}

var e environment
var client *fauna.FaunaClient

func loginUser(email string) (string, error) {
	expr := fauna.Create(fauna.Tokens(), fauna.Obj{"instance": fauna.Select("ref",
		fauna.Get(
			fauna.MatchTerm(fauna.Index("users_by_email"), email),
		),
	)})
	value, err := client.Query(expr)
	if err != nil {
		return "nil", err
	}
	var tokenStruct token
	err = value.Get(&tokenStruct)
	if err != nil {
		return "nil", err
	}

	return tokenStruct.FaunaToken, nil
}

// func handler(req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {

// }

func main() {
	_, err := env.UnmarshalFromEnviron(&e)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("KEY: ", e.FaunaSecret)
	client = fauna.NewFaunaClient(e.FaunaSecret)
	loginUser("alice@site.example")
	//lambda.Start(handler)
}
