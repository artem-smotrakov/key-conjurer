package keyconjurer

import (
	"encoding/json"
	"fmt"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestResponseMarshalJSON(t *testing.T) {
	type T struct {
		Foo, Bar string
	}

	data, _ := DataResponse(T{Foo: "Foo", Bar: "Qux"})
	b, _ := json.Marshal(data)

	require.Equal(t, `{"Success":true,"Message":"success","Data":{"Foo":"Foo","Bar":"Qux"}}`, string(b))
}

func TestResponseUnmarshalJSON(t *testing.T) {
	type T struct {
		Foo, Bar string
	}

	data := `{"Success":true,"Message":"success","Data":{"Foo":"Foo","Bar":"Qux"}}`

	var response Response
	err := response.UnmarshalJSON([]byte(data))
	require.Nil(t, err)

	var payload T
	err = response.GetPayload(&payload)
	require.Nil(t, err)
	require.Equal(t, payload.Foo, "Foo")
	require.Equal(t, payload.Bar, "Qux")
}

func TestErrorResponseMarshalJSON(t *testing.T) {
	message := "this is a error message"
	data, responseErr := ErrorResponse(ErrBadRequest, message)
	require.NotNil(t, responseErr)
	require.NotNil(t, data)
	require.IsType(t, ErrorData{}, data.Data)
	require.Equal(t, responseErr.Error(), data.Data.(ErrorData).Error())

	b, marshalErr := json.Marshal(data)
	require.Nil(t, marshalErr)
	expectedData := fmt.Sprintf(`{"Success":false,"Message":"%s","Data":{"Code":"bad_request","Message":"%s"}}`, message, message)
	require.Equal(t, expectedData, string(b))
}

func TestErrorResponseUnmarshalJSON(t *testing.T) {
	message := "this is a error message"
	var code ErrorCode = "bad_request"
	data := fmt.Sprintf(`{"Success":false,"Message":"%s","Data":{"Code":"%s","Message":"%s"}}`, message, code, message)

	var errorResponse Response
	err := errorResponse.UnmarshalJSON([]byte(data))
	require.Nil(t, err)

	var errorData ErrorData
	err = errorResponse.GetError(&errorData)
	require.Nil(t, err)
	require.Contains(t, errorData.Error(), message)
	require.Equal(t, errorData.Code, code)
}

func TestResponseGetPayload(t *testing.T) {
	payload := `{"Success":true,"Message":"","Data":{"foo": "bar", "qux": "baz"}}`
	var response Response
	var data map[string]string
	var err ErrorData
	require.Error(t, response.GetPayload(&data))
	require.Error(t, response.GetError(&err))
	require.NoError(t, json.Unmarshal([]byte(payload), &response))
	require.NoError(t, response.GetPayload(&data))
	require.Error(t, response.GetError(&err))
	require.Equal(t, "bar", data["foo"])
	require.Equal(t, "baz", data["qux"])
}

func TestResponseGetError(t *testing.T) {
	payload := `{"Success":false,"Data":{"Code": "unspecified", "Message": "Something broke"}}`
	var response Response
	var data map[string]string
	var err ErrorData
	require.Error(t, response.GetPayload(&data))
	require.NoError(t, json.Unmarshal([]byte(payload), &response))
	require.Error(t, response.GetPayload(&data))
	require.NoError(t, response.GetError(&err))
	require.Equal(t, "Something broke (code: unspecified)", err.Error())
}
