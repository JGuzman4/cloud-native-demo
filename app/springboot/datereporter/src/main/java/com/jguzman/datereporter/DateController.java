package com.jguzman.datereporter;

import java.util.Date;
import org.json.simple.JSONObject;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class DateController {

  @RequestMapping(value = "/", method = RequestMethod.GET)
  public JSONObject getDate() {
    JSONObject resp = new JSONObject();

    Date date = new Date();

    resp.put("date", date.toString());
    resp.put("message", "this is a demo");
    return resp;
  }
}
