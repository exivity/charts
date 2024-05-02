import sys
import unittest
import requests
import argparse

# Create a parser for the custom arguments
custom_parser = argparse.ArgumentParser(add_help=False)
custom_parser.add_argument(
    "--hostname", type=str, required=True, help="Hostname of the test server"
)
custom_parser.add_argument(
    "--ip", type=str, required=True, help="IP address of the test server"
)
custom_args, remaining_argv = custom_parser.parse_known_args()


class EndpointTestCase(unittest.TestCase):
    BASE_URL = f"http://{custom_args.ip}"

    TEST_CASES = [
        {
            "path": "/",
            "expected_status": 200,
            "method": "GET",
        },
        {
            "path": "/v1/auth/token",
            "expected_status": 200,
            "method": "POST",
            "headers": {
                "Content-Type": "application/x-www-form-urlencoded",
                "Accept": "application/json",
            },
            "data": "username=admin&password=exivity",
        },
    ]

    def test_endpoints(self):
        for case in self.TEST_CASES:
            with self.subTest(case=case):
                url = f"{self.BASE_URL}{case['path']}"
                headers = {"Host": custom_args.hostname}
                headers.update(case.get("headers", {}))
                data = case.get("data")
                response = requests.request(
                    method=case["method"], url=url, headers=headers, data=data
                )
                self.assertEqual(response.status_code, case["expected_status"])


if __name__ == "__main__":
    # Replace the system's argv with the remaining arguments after removing custom ones
    sys.argv[1:] = remaining_argv
    unittest.main()
