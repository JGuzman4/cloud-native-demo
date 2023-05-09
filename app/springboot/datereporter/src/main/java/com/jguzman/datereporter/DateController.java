package com.jguzman.datereporter;

import java.util.HashMap;
import java.util.Map;

import java.util.Date;
import org.json.simple.JSONObject;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class DateController {

  private Date date = new Date();

  @RequestMapping(value = "/", method = RequestMethod.GET)
  public JSONObject getDate() {
    JSONObject resp = new JSONObject();

    resp.put("date", date.toString());
    resp.put("message", "hello world");
    return resp;
  }
}
