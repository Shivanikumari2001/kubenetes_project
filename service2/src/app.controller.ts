import { Controller, Get } from '@nestjs/common';
import { AppService } from './app.service';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  getHello(): string {
    return this.appService.getHello();
  }

  @Get('health')
  getHealth() {
    return {
      status: 'ok',
      service: 'service2',
      timestamp: new Date().toISOString(),
    };
  }

  @Get('data')
  getData() {
    return {
      service: 'service2',
      message: 'Data from Service 2',
      data: {
        id: 2,
        name: 'Service 2 Data',
        value: 200,
      },
    };
  }
}

// trigger pipeline test
//hgjhgjh