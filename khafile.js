let project = new Project('PONG 2');

project.addSources('src');
project.addAssets('res/**/!(*.mp3)', {
	nameBaseDir: 'res',
	destination: '{dir}/{name}',
	name: '{dir}/{name}'
});
project.addAssets('res/*/**.(mp3)', {
	quality: 0.5,
	nameBaseDir: 'res',
	destination: '{dir}/{name}',
	name: '{dir}/{name}'
});

project.addDefine('kha_no_ogg');
project.addDefine('analyzer-optimize');
project.addParameter('-dce full');
project.targetOptions.html5.disableContextMenu = true;

if (process.argv.includes("--watch")) {
	let libPath = project.addLibrary('hotml');
	project.addDefine('js_classic');
	const path = require('path');
	const Server = require(`${libPath}/bin/server.js`).hotml.server.Main;
	const server = new Server(`${path.resolve('.')}/build/${platform}`, 'kha.js');
	callbacks.postHaxeRecompilation = () => {
		server.reload();
	}
	callbacks.postAssetReexporting = (path) => {
		server.reloadAsset(path);
	}
}

resolve(project);
