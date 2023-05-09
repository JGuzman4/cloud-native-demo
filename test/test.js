import http from "k6/http";
import { Rate, Trend } from "k6/metrics";

export let options = {
  vus: __ENV.LOAD_TEST_VUS || 2, // number of virtual users
  duration: "600s", // duration of the test
};

// track success rate
export let successRate = new Rate("success_rate");

// track error rate
export let errorRate = new Rate("error_rate");

// track TTLB (time to last byte)
export let ttlb = new Trend("ttlb");

export default function () {
  const start = new Date().getTime();

  const res = http.get(__ENV.DATEREPORTER_URL);

  const end = new Date().getTime();
  const duration = end - start;

  successRate.add(res.status === 200);
  errorRate.add(res.status !== 200);
  ttlb.add(duration);
}
