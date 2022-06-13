function load(url, params) {
    var a = fetch(url, params);
    register_plugins(plugins),
        typeof WebAssembly.compileStreaming == 'function' ? WebAssembly.compileStreaming(a).then(a=>(add_missing_functions_stabs(a), WebAssembly.instantiate(a, importObject))).then(a=>{
            wasm_memory = a.exports.memory,
                wasm_exports = a.exports;
            var b = u32_to_semver(wasm_exports.crate_version());
            version != b && console.error('Version mismatch: gl.js version is: ' + version + ', rust sapp-wasm crate version is: ' + b),
                init_plugins(plugins),
                a.exports.main()
            document.querySelector("#compile-btn").innerHTML = "Compile";
        }).catch(a=>{
            console.error('WASM failed to load, probably incompatible gl.js version'),
                console.error(a)
        }) : a.then(function (a) {
            return a.arrayBuffer()
        }).then(function (a) {
            return WebAssembly.compile(a)
        }).then(function (a) {
            return add_missing_functions_stabs(a),
                WebAssembly.instantiate(a, importObject)
        }).then(function (a) {
            wasm_memory = a.exports.memory,
                wasm_exports = a.exports;
            var b = u32_to_semver(wasm_exports.crate_version());
            version != b && console.error('Version mismatch: gl.js version is: ' + version + ', rust sapp-wasm crate version is: ' + b),
                init_plugins(plugins),
                a.exports.main()
        }).catch(a=>{
            console.error('WASM failed to load, probably incompatible gl.js version'),
                console.error(a)
        })
}

let editor = ace.edit("editor")
editor.session.setMode("ace/mode/rust");

function compile_and_load() {
    document.querySelector("#compile-btn").innerHTML = "Compiling...";

    let params = {
        body: JSON.stringify({ code: editor.getValue() }),
        method: "POST"
    };

    load("/compile", params)
}
