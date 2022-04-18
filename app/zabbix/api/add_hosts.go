package main

import (
	"bytes"
	"encoding/json"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"strings"
)

type Payload struct {
	JSON_RPC string      `json:"jsonrpc"`
	Method   string      `json:"method"`
	Params   interface{} `json:"params"`
	Auth     string      `json:"auth,omitempty"`
	Id       int         `json:"id"`
}

type Response struct {
	JSON_RPC string        `json:"jsonrpc"`
	Result   []interface{} `json:"result,omitempty"`
	Error    interface{}   `json:"error,omitempty"`
	Id       int           `json:"id"`
}

type Response_variant struct {
	JSON_RPC string      `json:"jsonrpc"`
	Result   interface{} `json:"result,omitempty"`
	Error    interface{} `json:"error,omitempty"`
	Id       int         `json:"id"`
}

type Api struct {
	url   string
	token string
}

type Template struct {
	TemplateId string `json:"templateid"`
}

type Host struct {
	Host       string      `json:"host"`
	Groups     []Group     `json:"groups"`
	Interfaces []Interface `json:"interfaces,omitempty"`
	Templates  []Template  `json:"templates,omitempty"`
	Macros     []Macro     `json:"macros,omitempty"`
}

type Group struct {
	GroupId string `json:"groupid"`
}

type Interface struct {
	Type  int    `json:"type"`
	Main  int    `json:"main"`
	UseIp int    `json:"useip"`
	Ip    string `json:"ip"`
	Dns   string `json:"dns"`
	Port  string `json:"port"`
}

type Macro struct {
	Macro string `json:"macro"`
	Value string `json:"value"`
}

func (a Api) post(method string, params interface{}) []byte {
	payload := Payload{}
	if method == "user.login" {
		payload = Payload{
			JSON_RPC: "2.0",
			Method:   method,
			Params:   params,
			Id:       1,
		}
	} else {
		payload = Payload{
			JSON_RPC: "2.0",
			Method:   method,
			Params:   params,
			Auth:     a.token,
			Id:       1,
		}
	}

	body, err := json.Marshal(payload)
	if err != nil {
		log.Println("Error while executing Unmarshal")
		log.Fatalf("Reason : %s", err)
	}

	resp, err := http.Post(a.url, "application/json-rpc", bytes.NewReader(body))
	if err != nil {
		log.Println("Error while authenticating to the zabbix server.")
		log.Fatalf("Reason : %v", err)
	}

	defer resp.Body.Close()
	data, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Println("Error while handling response.")
		log.Fatalf("Reason : %s", err)
	}

	return data
}

func (a Api) auth() string {
	body := map[string]string{
		"user":     "Admin",
		"password": "zabbix",
	}

	resp := a.post("user.login", body)

	data := Response_variant{}
	err := json.Unmarshal(resp, &data)
	if err != nil {
		log.Println("Error while executing Unmarshal")
		log.Fatalf("Reason : %s", err)
	}

	token := data.Result.(string)
	if token == "" {
		log.Println("Error while retrieving auth token")
		log.Fatalf("Reason : %v", data.Error)
	}

	return token
}

func (a Api) get_templateid(name string) string {
	body := map[string]interface{}{
		"filter": map[string][]string{
			"name": {
				name,
			},
		},
	}

	resp := a.post("template.get", body)

	data := Response{}
	err := json.Unmarshal(resp, &data)
	if err != nil {
		log.Println("Error while executing Unmarshal")
		log.Fatalf("Reason : %s", err)
	}

	if len(data.Result) == 0 {
		log.Printf("No template with the name '%s' found.", name)
		return ""
	}

	template := data.Result[0].(map[string]interface{})
	return template["templateid"].(string)
}

func (a Api) get_groupid(name string) string {
	body := map[string]interface{}{
		"filter": map[string][]string{
			"name": {
				name,
			},
		},
	}

	resp := a.post("hostgroup.get", body)

	data := Response{}
	err := json.Unmarshal(resp, &data)
	if err != nil {
		log.Println("Error while executing Unmarshal")
		log.Fatalf("Reason : %s", err)
	}

	if len(data.Result) == 0 {
		log.Fatalf("No Hostgroup with the name '%s' found.", name)
		return ""
	}

	template := data.Result[0].(map[string]interface{})
	return template["groupid"].(string)
}

func (a Api) get_hostid(name string) string {
	body := map[string]interface{}{
		"filter": map[string][]string{
			"name": {
				name,
			},
		},
	}

	resp := a.post("host.get", body)

	data := Response{}
	err := json.Unmarshal(resp, &data)
	if err != nil {
		log.Println("Error while executing Unmarshal")
		log.Fatalf("Reason : %s", err)
	}

	if len(data.Result) == 0 {
		log.Printf("No Host with the name '%s' found.", name)
		return ""
	}

	template := data.Result[0].(map[string]interface{})
	return template["hostid"].(string)
}

func (a Api) add_host(host Host) {
	resp := a.post("host.create", host)

	data := Response_variant{}
	err := json.Unmarshal(resp, &data)
	if err != nil {
		log.Println("Error while executing Unmarshal")
		log.Fatalf("Reason : %s", err)
	}

	if data.Error != nil {
		log.Printf("Error while adding host : %v", host)
		log.Fatalf("Reason : %s", data.Error)
	}

	log.Printf("Host '%s' was added succesfully.", host.Host)
}

func main() {
	KUBE_API_SERVER := os.Args[1]
	KUBE_API_SERVER_ENDPOINT := KUBE_API_SERVER + "/api"
	ZABBIX_SA_TOKEN := os.Args[2]
	ZABBIX_WEB_IP := os.Args[3]
	ZABBIX_WEB_PORT := os.Args[4]

	KUBE_API_SERVER_elements := strings.Split(KUBE_API_SERVER, ":")
	KUBE_API_SERVER_IP := KUBE_API_SERVER_elements[1]
	// Remove the http:// form the url
	KUBE_API_SERVER_IP = strings.ReplaceAll(KUBE_API_SERVER_IP, "/", "")
	KUBE_API_SERVER_PORT := KUBE_API_SERVER_elements[2]

	URL := "http://" + ZABBIX_WEB_IP + ":" + ZABBIX_WEB_PORT + "/api_jsonrpc.php"

	HOST_GROUP := "Templates/Virtualization"
	// Host using the "Kubernetes nodes by HTTP" template
	HOST_1_NAME := "Local k8s cluster - 2"
	HOST_1_TEMPLATE := "Kubernetes nodes by HTTP"
	// Host using the "Kubernetes cluster state by HTTP" template
	HOST_2_NAME := "Local k8s cluster - state - 2"
	HOST_2_TEMPLATE := "Kubernetes cluster state by HTTP"

	api := Api{
		url: URL,
	}
	token := api.auth()
	api.token = token

	host_group_id := api.get_groupid(HOST_GROUP)
	host_1_template_id := api.get_templateid(HOST_1_TEMPLATE)
	host_2_template_id := api.get_templateid(HOST_2_TEMPLATE)

	host_1_exist := api.get_hostid(HOST_1_NAME)
	if host_1_exist == "" {
		node_1_host := Host{
			Host: HOST_1_NAME,
			Groups: []Group{
				{
					GroupId: host_group_id,
				},
			},
			Interfaces: []Interface{
				{
					// 1 = agent
					Type: 1,
					Main: 1,
					Ip:   "127.0.0.1",
					// Connect using IP
					UseIp: 1,
					Dns:   "",
					Port:  "10050",
				},
			},
			Templates: []Template{
				{
					TemplateId: host_1_template_id,
				},
			},
			Macros: []Macro{
				{
					Macro: "{$KUBE.API.ENDPOINT}",
					Value: KUBE_API_SERVER_ENDPOINT,
				},
				{
					Macro: "{$KUBE.API.TOKEN}",
					Value: ZABBIX_SA_TOKEN,
				},
			},
		}
		api.add_host(node_1_host)
	} else {
		log.Printf("Host '%s' already exist. Continuing without modification.", HOST_1_NAME)
	}
	host_2_exist := api.get_hostid(HOST_2_NAME)
	if host_2_exist == "" {
		node_2_host := Host{
			Host: HOST_2_NAME,
			Groups: []Group{
				{
					GroupId: host_group_id,
				},
			},
			Interfaces: []Interface{
				{
					// 1 = agent
					Type: 1,
					Main: 1,
					Ip:   "127.0.0.1",
					// Connect using IP
					UseIp: 1,
					Dns:   "",
					Port:  "10050",
				},
			},
			Templates: []Template{
				{
					TemplateId: host_2_template_id,
				},
			},
			Macros: []Macro{
				{
					Macro: "{$KUBE.API.HOST}",
					Value: KUBE_API_SERVER_IP,
				},
				{
					Macro: "{$KUBE.API.PORT}",
					Value: KUBE_API_SERVER_PORT,
				},
				{
					Macro: "{$KUBE.API.TOKEN}",
					Value: ZABBIX_SA_TOKEN,
				},
			},
		}
		api.add_host(node_2_host)
	} else {
		log.Printf("Host '%s' already exist. Continuing without modification.", HOST_2_NAME)
	}
}
