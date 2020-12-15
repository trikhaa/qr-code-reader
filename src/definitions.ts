declare module '@capacitor/core' {
  interface PluginRegistry {
    QRCodePlugin: QRCodePluginPlugin;
  }
}

export interface QRCodePluginPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
  scanCode(filter:string):Promise<{results:any[]}>;
}
