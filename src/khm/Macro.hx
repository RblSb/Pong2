package khm;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
using haxe.macro.Tools;

class EnumAbstractTools {

	macro public static function fromString(name:Expr, typePath:Expr):Expr {
		final type = Context.getType(typePath.toString());
		final name = name.toString();
		switch (type.follow()) {
			case TAbstract(_.get() => ab, _) if (isEnumAbstract(ab)):
				final code = new StringBuf();
				code.add('switch ($name) {');
				for (field in ab.impl.get().statics.get()) {
					if (isEnumAbstractField(field)) {
						code.add('case "${field.name}": ${field.name};');
					}
				}
				code.add('default: throw("Unknown case " + $name);}');
				return Context.parse(code.toString(), Context.currentPos());
			default:
				throw new Error(type.toString() + " should be enum abstract", typePath.pos);
		}
	}

	macro public static function toString(name:Expr, typePath:Expr):Expr {
		final type = Context.getType(typePath.toString());
		final name = name.toString();
		switch (type.follow()) {
			case TAbstract(_.get() => ab, _) if (isEnumAbstract(ab)):
				final code = new StringBuf();
				code.add('switch ($name) {');
				for (field in ab.impl.get().statics.get()) {
					if (isEnumAbstractField(field)) {
						code.add('case ${field.name}: "${field.name}";');
					}
				}
				code.add("}");
				return Context.parse(code.toString(), Context.currentPos());
			default:
				throw new Error(type.toString() + " should be enum abstract", typePath.pos);
		}
	}

	macro public static function getIndex(typePath:Expr):Expr {
		final type = Context.typeof(typePath);
		final name = typePath.toString();
		var index = 0;
		switch (type.follow()) {
			case TAbstract(_.get() => ab, _) if (isEnumAbstract(ab)):
				final code = new StringBuf();
				code.add('switch ($name) {');
				for (field in ab.impl.get().statics.get()) {
					if (isEnumAbstractField(field)) {
						code.add('case ${field.name}: $index;');
						index++;
					}
				}
				code.add("}");
				return Context.parse(code.toString(), Context.currentPos());
			default:
				throw new Error(type.toString() + " should be enum abstract", typePath.pos);
		}
	}

	static function isEnumAbstract(ab:AbstractType):Bool {
		return ab.meta.has(":enum");
	}

	static function isEnumAbstractField(field:ClassField):Bool {
		return field.meta.has(":enum") && field.meta.has(":impl");
	}

}

class Macro {

	macro public static function getTypedObject(obj:Expr, typePath:Expr):Expr {
		final type = Context.getType(typePath.toString());
		switch (type.follow()) {
			case TAnonymous(_.get() => td):
				final name = obj.toString();
				final code = new StringBuf();
				code.add("{");
				for (field in td.fields) {
					code.add('${field.name}: $name.${field.name}, ');
				}
				code.add("}");
				return Context.parse(code.toString(), Context.currentPos());
			default:
				throw new Error(type.toString() + " should be type", typePath.pos);
		}
	}

	macro public static function getBuildTime():Expr {
		return macro $v{Date.now().toString()};
	}

	macro public static function getDefine(id:String): Expr {
		return {
			expr: EConst(CString(Context.getDefines().get(id))),
			pos: Context.currentPos()
		};
	}

}
