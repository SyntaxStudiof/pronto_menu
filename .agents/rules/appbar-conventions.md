# Convenzioni AppBar & UI - ProntoMenu

## Pattern AppBar Obbligatorio
Ogni AppBar nelle schermate interne dell'app deve rispettare:
1. `elevation: 0.0`
2. `centerTitle: true`
3. `automaticallyImplyLeading: false`
4. `leading: FlutterFlowIconButton` con `Icons.arrow_back_rounded` (buttonSize: 40.0)
5. `title`: `Row(mainAxisSize: MainAxisSize.min)` con:
   - `Container` 36x36, `primary.withValues(alpha: 0.12)`, `borderRadius: BorderRadius.circular(10.0)`, contenente l'icona della pagina in `primary` da 20px.
   - `SizedBox(width: 10.0)`
   - `Text` con `fontSize: 18.0 - 20.0`, `fontWeight: FontWeight.bold`, `letterSpacing: -0.4`.
6. `actions`: se vuota, inserire sempre `const [SizedBox(width: 48.0)]` per garantire la perfetta centratura ottica rispetto al leading.
