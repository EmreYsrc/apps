from locust import HttpUser, SequentialTaskSet, task, constant

class HomeLoadTest(SequentialTaskSet):

    def on_start(self):
        print("Services started")

    @task
    def home_page(self):
        with self.client.get("/", catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Failed to load home page: {response.status_code}")

    @task
    def keycloak(self):
        with self.client.get("/success", catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Failed to load keycloak page: {response.status_code}")

    def on_stop(self):
        print("Service stopped")

class HomePageLoadTest(HttpUser):
    wait_time = constant(1)
    tasks = [HomeLoadTest]
    host = "https://keycloak.test.voltran.link"



