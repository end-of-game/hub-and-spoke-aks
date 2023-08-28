Bookinfo Sample

The Bookinfo app is a sample microservices application that demonstrates various Kubernetes features. It is made up of four microservices:

productpage: The productpage microservice calls the details and reviews microservices to populate the page.
details: The details microservice contains book information.
reviews: The reviews microservice contains book reviews. It also calls the ratings microservice.
ratings: The ratings microservice contains book rating information.
Prerequisites
Before you can run the Bookinfo app, you must have the following installed:

Azure Kubernets Service
Istio-Addon
Argo CD
