# autoloads/data_manager.gd
# JEDYNY punkt dostępu do localStorage.
# NIE wywoływaj JavaScriptBridge.eval() nigdzie poza tym plikiem.
extends Node

# Wewnętrzny cache — unikamy zbędnych wywołań JS
var _cache: Dictionary = {}


func _ready() -> void:
	if OS.is_debug_build():
		print("[DataManager] Inicjalizacja. Web: ", OS.has_feature("web"))


## Zapisuje wartość do localStorage (i lokalnego cache).
## Klucz musi być z Constants — nigdy hardcoded string.
## Zwraca true jeśli zapis się powiódł.
func save(key: String, data: Variant) -> bool:
	var json_string: String = JSON.stringify(data)
	if json_string.length() > Constants.STORAGE_MAX_BYTES:
		push_error("[DataManager] Dane przekraczają limit: " + key)
		return false

	_cache[key] = data

	if OS.has_feature("web"):
		var escaped: String = json_string.replace("\\", "\\\\").replace("'", "\\'")
		JavaScriptBridge.eval("localStorage.setItem('" + key + "', '" + escaped + "')")
	else:
		if OS.is_debug_build():
			print("[DataManager] TRYB EDITOR — dane nie są persystowane: ", key)

	return true


## Odczytuje wartość z localStorage (lub cache).
## Zwraca null jeśli klucz nie istnieje.
func load_data(key: String) -> Variant:
	if _cache.has(key):
		return _cache[key]

	if OS.has_feature("web"):
		var result: Variant = JavaScriptBridge.eval("localStorage.getItem('" + key + "')")
		if result == null or str(result) == "null":
			return null
		var parsed: Variant = JSON.parse_string(str(result))
		_cache[key] = parsed
		return parsed

	return null


## Usuwa klucz z localStorage i cache.
func delete(key: String) -> void:
	_cache.erase(key)
	if OS.has_feature("web"):
		JavaScriptBridge.eval("localStorage.removeItem('" + key + "')")
	if OS.is_debug_build():
		print("[DataManager] Usunięto klucz: ", key)


## Sprawdza czy klucz istnieje.
func has_key(key: String) -> bool:
	if _cache.has(key):
		return true
	return load_data(key) != null


## Czyści cały localStorage i cache. UWAGA: nieodwracalne.
func clear_all() -> void:
	_cache.clear()
	if OS.has_feature("web"):
		JavaScriptBridge.eval("localStorage.clear()")
	if OS.is_debug_build():
		print("[DataManager] Wyczyszczono localStorage")
