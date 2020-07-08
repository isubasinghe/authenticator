package main

import (
	"context"
	"fmt"
	"log"

	firebase "firebase.google.com/go/v4"
	_ "firebase.google.com/go/v4/auth"
	env "github.com/Netflix/go-env"
	fauna "github.com/fauna/faunadb-go/faunadb"
	"google.golang.org/api/option"
)

type environment struct {
	FaunaSecret            string `env:"FAUNADB_SECRET"`
	FirebaseSecretLocation string `env:"FIREBASE_SECRET_LOCATION"`
}

type token struct {
	FaunaToken string `fauna:"secret"`
}

var e environment
var client *fauna.FaunaClient
var app *firebase.App
var ctx context.Context

func loginUser(uid string) (string, error) {
	expr := fauna.Create(fauna.Tokens(), fauna.Obj{"instance": fauna.Select("ref",
		fauna.Get(
			fauna.MatchTerm(fauna.Index("users_by_uid"), uid),
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

func getUID(idToken string) (string, error) {
	msg := "nil"
	client, err := app.Auth(ctx)
	if err != nil {
		return msg, err
	}
	token, err := client.VerifyIDTokenAndCheckRevoked(ctx, idToken)
	if err != nil {
		return msg, err
	}
	msg = token.UID
	return msg, nil
}

func main() {
	var err error
	_, err = env.UnmarshalFromEnviron(&e)

	opt := option.WithCredentialsFile(e.FirebaseSecretLocation)
	ctx = context.Background()
	app, err = firebase.NewApp(ctx, nil, opt)
	if err != nil {
		log.Fatal(err)
	}
	if err != nil {
		log.Fatal(err)
	}
	client = fauna.NewFaunaClient(e.FaunaSecret)

	fmt.Println(loginUser("1234"))

}
