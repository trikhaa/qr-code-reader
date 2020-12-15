import { WebPlugin } from '@capacitor/core';
import { QRCodePluginPlugin } from './definitions';

export class QRCodePluginWeb extends WebPlugin implements QRCodePluginPlugin {
  constructor() {
    super({
      name: 'QRCodePlugin',
      platforms: ['web'],
    });
  }

  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
  async scanCode(filter:string):Promise<{results:any[]}> {
    console.log('ECHO', filter);
    return {
      results: [{
        firstName: 'Dummy',
        lastName: 'Entry',
        telephone: '123456'
      }]
    };
  }
}

const QRCodePlugin = new QRCodePluginWeb();

export { QRCodePlugin };

import { registerWebPlugin } from '@capacitor/core';
registerWebPlugin(QRCodePlugin);
