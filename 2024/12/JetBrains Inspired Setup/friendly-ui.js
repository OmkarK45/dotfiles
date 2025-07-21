const basePath = '../../../../'

const loadJsFile = async (path, callback, isImport) => {
	const resp = await fetch(
		(path.startsWith('./') ? path : basePath + path) + '.js'
	)
	const respText = await resp.text()
	const newText = callback ? await callback(respText) : respText
	const blob = new Blob([newText], { type: 'application/javascript' })
	const url = URL.createObjectURL(blob)

	return isImport ? await import(url) : url
}

const replaceCommandPannelHeight = (text) => {
	const commandPannelHeight = 36
	// command panel item height
	// getHeight(i){return i instanceof iO?30:i.saneDetail?44:22}
	text = text.replace(
		/(44:)22(?=})/g,
		(_, prefix) => `${prefix}${commandPannelHeight}`
	)
	return text
}

const replaceItemHeight = (text) => {
	const itemHeight = 30
	// item height
	let replaceItemH = (_, prefix) => `${prefix}${itemHeight}`
	text = text.replace(/(eight\([^)]*?\)\{return )22(?!\d)/g, replaceItemH)
	text = text.replace(/(ITEM_HEIGHT=)22(?!\d)/g, replaceItemH)
	text = text.replace(/(\*)22(?!\d)/g, replaceItemH)
	text = text.replace(/(:)22(?=})/g, replaceItemH)
	return text
}

;(async function () {
	const mainJsPath = 'vs/workbench/workbench.desktop.main'
	await loadJsFile(
		'./workbench',
		async (text) => {
			const mainJsUrl = await loadJsFile(mainJsPath, (text) => {
				text = replaceCommandPannelHeight(text)
				text = replaceItemHeight(text)
				return text
			})
			return text.replace(mainJsPath, mainJsUrl + '#')
		},
		true
	)
})()
