package com.graceful.shutdown;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Mono;

@RestController
@RequestMapping("/hola")
public class HelloController {

  @RequestMapping("/amigo")
  public Mono<String>  saludar(){
    return Mono.just("buenos dias");
  }
}
