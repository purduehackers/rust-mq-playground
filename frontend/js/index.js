let code = `
use macroquad::prelude::*;

#[macroquad::main("BasicShapes")]
async fn main() {
    loop {
        clear_background(RED);

        draw_line(40.0, 40.0, 100.0, 200.0, 15.0, BLUE);
        draw_rectangle(screen_width() / 2.0 - 60.0, 100.0, 120.0, 60.0, GREEN);
        draw_circle(screen_width() - 30.0, screen_height() - 30.0, 15.0, YELLOW);

        draw_text("IT WORKS!", 20.0, 20.0, 30.0, DARKGRAY);

        next_frame().await
    }
}
`;

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
// editor.setTheme("ace/theme/monokai");
// editor.session.setMode("ace/mode/rust");

function compile_and_load() {
    let params = {
        body: JSON.stringify({ code: editor.getValue() }),
        method: "POST"
    };

    load("/compile", params)
}
