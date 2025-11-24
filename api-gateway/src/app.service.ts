import { Injectable } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { Request, Response } from 'express';
import { firstValueFrom, timeout } from 'rxjs';

@Injectable()
export class AppService {
  private readonly serviceUrls = {
    service1: process.env.SERVICE1_URL || 'http://127.0.0.1:3001',
    service2: process.env.SERVICE2_URL || 'http://127.0.0.1:3002',
  };

  constructor(private readonly httpService: HttpService) {}

  async proxyRequest(serviceName: string, req: Request, res: Response) {
    try {
      const baseUrl = this.serviceUrls[serviceName];
      if (!baseUrl) {
        return res.status(404).json({ message: 'Service not found' });
      }

      //kjkdjk Extract the path after service name
      let path = req.path;
      if (path.startsWith('/api/users')) {
        path = path.replace('/api', '');
      } else if (path.startsWith('/api/payments')) {
        path = path.replace('/api', '');
      } else if (path.startsWith(`/api/service1/`)) {
        path = path.replace('/api/service1', '');
      } else if (path.startsWith(`/api/service2/`)) {
        path = path.replace('/api/service2', '');
      } else if (path === '/service1' || path.startsWith('/service1/')) {
        path = path.replace('/service1', '') || '/';
      } else if (path === '/service2' || path.startsWith('/service2/')) {
        path = path.replace('/service2', '') || '/';
      } else if (path.startsWith('/api/')) {
        path = path.replace('/api/', '').replace(serviceName, '');
        if (!path.startsWith('/')) path = '/' + path;
      }

      const url = `${baseUrl}${path}`;
      const queryString = req.url.includes('?') ? req.url.split('?')[1] : '';
      const fullUrl = queryString ? `${url}?${queryString}` : url;

      // Clean headers - remove problematic ones
      const headers: any = {};
      Object.keys(req.headers).forEach(key => {
        const lowerKey = key.toLowerCase();
        // Skip headers that shouldn't be forwarded
        if (!['host', 'connection', 'content-length'].includes(lowerKey)) {
          headers[key] = req.headers[key];
        }
      });
      
      // Set content-type if body exists
      if (['POST', 'PUT', 'PATCH'].includes(req.method) && req.body) {
        headers['content-type'] = 'application/json';
      }

      const config: any = {
        method: req.method as any,
        url: fullUrl,
        timeout: 10000, // Reduced timeout to 10s
        headers,
      };

      // Add body for POST, PUT, PATCH requests
      if (['POST', 'PUT', 'PATCH'].includes(req.method) && req.body) {
        config.data = req.body;
      }

      const response = await firstValueFrom(
        this.httpService.request(config).pipe(
          timeout(10000)
        )
      );

      return res.status(response.status).json(response.data);
    } catch (error: any) {
      console.error(`Error proxying to ${serviceName}:`, error.message);
      //hkjhjkhjj
      // Handle different error types
      let statusCode = 500;
      let errorMessage = error.message;
      
      if (error.response) {
        // HTTP error response
        statusCode = error.response.status;
        errorMessage = error.response.data || error.message;
      } else if (error.code === 'ECONNREFUSED' || error.code === 'ETIMEDOUT') {
        // Connection/timeout errors
        statusCode = 503;
        errorMessage = `Service ${serviceName} is unavailable`;
      } else if (error.name === 'TimeoutError') {
        statusCode = 504;
        errorMessage = 'Request timeout';
      }
      
      return res.status(statusCode).json({
        message: `Error proxying to ${serviceName}`,
        error: errorMessage,
      });
    }
  }
}

