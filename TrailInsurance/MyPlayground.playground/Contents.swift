import UIKit
// To parse the JSON, add this file to your project and do:
//
//   let caseCompactLayout = try? newJSONDecoder().decode(CaseCompactLayout.self, from: jsonData)

import Foundation

struct CaseCompactLayout: Codable {
	let caseCompactLayoutCase: Case
	
	enum CodingKeys: String, CodingKey {
		case caseCompactLayoutCase = "Case"
	}
}

struct `Case`: Codable {
	let actions: JSONNull?
	let fieldItems: [FieldItem]
	let id: String
	let imageItems: JSONNull?
	let label, name, objectType: String
}

struct FieldItem: Codable {
	let editableForNew, editableForUpdate: Bool
	let label: String
	let layoutComponents: [LayoutComponent]
	let placeholder, fieldItemRequired: Bool
	
	enum CodingKeys: String, CodingKey {
		case editableForNew, editableForUpdate, label, layoutComponents, placeholder
		case fieldItemRequired = "required"
	}
}

struct LayoutComponent: Codable {
	let details: Details
	let displayLines, tabOrder: Int
	let type, value: String
}

struct Details: Codable {
	let aggregatable, aiPredictionField, autoNumber: Bool
	let byteLength: Int
	let calculated: Bool
	let calculatedFormula: JSONNull?
	let cascadeDelete, caseSensitive: Bool
	let compoundFieldName, controllerName: JSONNull?
	let createable, custom: Bool
	let defaultValue, defaultValueFormula: JSONNull?
	let defaultedOnCreate, dependentPicklist, deprecatedAndHidden: Bool
	let digits: Int
	let displayLocationInDecimal, encrypted, externalID: Bool
	let extraTypeInfo: JSONNull?
	let filterable: Bool
	let filteredLookupInfo: JSONNull?
	let formulaTreatNullNumberAsZero, groupable, highScaleNumber, htmlFormatted: Bool
	let idLookup: Bool
	let inlineHelpText: JSONNull?
	let label: String
	let length: Int
	let mask, maskType: JSONNull?
	let name: String
	let nameField, namePointing, nillable, permissionable: Bool
	let picklistValues: JSONNull?
	let polymorphicForeignKey: Bool
	let precision: Int
	let queryByDistance: Bool
	let referenceTargetField: JSONNull?
	let referenceTo: [JSONAny]
	let relationshipName, relationshipOrder: JSONNull?
	let restrictedDelete, restrictedPicklist: Bool
	let scale: Int
	let searchPrefilterable: Bool
	let soapType: String
	let sortable: Bool
	let type: String
	let unique, updateable, writeRequiresMasterRead: Bool
	
	enum CodingKeys: String, CodingKey {
		case aggregatable, aiPredictionField, autoNumber, byteLength, calculated, calculatedFormula, cascadeDelete, caseSensitive, compoundFieldName, controllerName, createable, custom, defaultValue, defaultValueFormula, defaultedOnCreate, dependentPicklist, deprecatedAndHidden, digits, displayLocationInDecimal, encrypted
		case externalID = "externalId"
		case extraTypeInfo, filterable, filteredLookupInfo, formulaTreatNullNumberAsZero, groupable, highScaleNumber, htmlFormatted, idLookup, inlineHelpText, label, length, mask, maskType, name, nameField, namePointing, nillable, permissionable, picklistValues, polymorphicForeignKey, precision, queryByDistance, referenceTargetField, referenceTo, relationshipName, relationshipOrder, restrictedDelete, restrictedPicklist, scale, searchPrefilterable, soapType, sortable, type, unique, updateable, writeRequiresMasterRead
	}
}

// MARK: Encode/decode helpers

class JSONNull: Codable, Hashable {
	
	public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
		return true
	}
	
	public var hashValue: Int {
		return 0
	}
	
	public init() {}
	
	public required init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		if !container.decodeNil() {
			throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
		}
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encodeNil()
	}
}

class JSONCodingKey: CodingKey {
	let key: String
	
	required init?(intValue: Int) {
		return nil
	}
	
	required init?(stringValue: String) {
		key = stringValue
	}
	
	var intValue: Int? {
		return nil
	}
	
	var stringValue: String {
		return key
	}
}

class JSONAny: Codable {
	let value: Any
	
	static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
		let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
		return DecodingError.typeMismatch(JSONAny.self, context)
	}
	
	static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
		let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
		return EncodingError.invalidValue(value, context)
	}
	
	static func decode(from container: SingleValueDecodingContainer) throws -> Any {
		if let value = try? container.decode(Bool.self) {
			return value
		}
		if let value = try? container.decode(Int64.self) {
			return value
		}
		if let value = try? container.decode(Double.self) {
			return value
		}
		if let value = try? container.decode(String.self) {
			return value
		}
		if container.decodeNil() {
			return JSONNull()
		}
		throw decodingError(forCodingPath: container.codingPath)
	}
	
	static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
		if let value = try? container.decode(Bool.self) {
			return value
		}
		if let value = try? container.decode(Int64.self) {
			return value
		}
		if let value = try? container.decode(Double.self) {
			return value
		}
		if let value = try? container.decode(String.self) {
			return value
		}
		if let value = try? container.decodeNil() {
			if value {
				return JSONNull()
			}
		}
		if var container = try? container.nestedUnkeyedContainer() {
			return try decodeArray(from: &container)
		}
		if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self) {
			return try decodeDictionary(from: &container)
		}
		throw decodingError(forCodingPath: container.codingPath)
	}
	
	static func decode(from container: inout KeyedDecodingContainer<JSONCodingKey>, forKey key: JSONCodingKey) throws -> Any {
		if let value = try? container.decode(Bool.self, forKey: key) {
			return value
		}
		if let value = try? container.decode(Int64.self, forKey: key) {
			return value
		}
		if let value = try? container.decode(Double.self, forKey: key) {
			return value
		}
		if let value = try? container.decode(String.self, forKey: key) {
			return value
		}
		if let value = try? container.decodeNil(forKey: key) {
			if value {
				return JSONNull()
			}
		}
		if var container = try? container.nestedUnkeyedContainer(forKey: key) {
			return try decodeArray(from: &container)
		}
		if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key) {
			return try decodeDictionary(from: &container)
		}
		throw decodingError(forCodingPath: container.codingPath)
	}
	
	static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
		var arr: [Any] = []
		while !container.isAtEnd {
			let value = try decode(from: &container)
			arr.append(value)
		}
		return arr
	}
	
	static func decodeDictionary(from container: inout KeyedDecodingContainer<JSONCodingKey>) throws -> [String: Any] {
		var dict = [String: Any]()
		for key in container.allKeys {
			let value = try decode(from: &container, forKey: key)
			dict[key.stringValue] = value
		}
		return dict
	}
	
	static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
		for value in array {
			if let value = value as? Bool {
				try container.encode(value)
			} else if let value = value as? Int64 {
				try container.encode(value)
			} else if let value = value as? Double {
				try container.encode(value)
			} else if let value = value as? String {
				try container.encode(value)
			} else if value is JSONNull {
				try container.encodeNil()
			} else if let value = value as? [Any] {
				var container = container.nestedUnkeyedContainer()
				try encode(to: &container, array: value)
			} else if let value = value as? [String: Any] {
				var container = container.nestedContainer(keyedBy: JSONCodingKey.self)
				try encode(to: &container, dictionary: value)
			} else {
				throw encodingError(forValue: value, codingPath: container.codingPath)
			}
		}
	}
	
	static func encode(to container: inout KeyedEncodingContainer<JSONCodingKey>, dictionary: [String: Any]) throws {
		for (key, value) in dictionary {
			let key = JSONCodingKey(stringValue: key)!
			if let value = value as? Bool {
				try container.encode(value, forKey: key)
			} else if let value = value as? Int64 {
				try container.encode(value, forKey: key)
			} else if let value = value as? Double {
				try container.encode(value, forKey: key)
			} else if let value = value as? String {
				try container.encode(value, forKey: key)
			} else if value is JSONNull {
				try container.encodeNil(forKey: key)
			} else if let value = value as? [Any] {
				var container = container.nestedUnkeyedContainer(forKey: key)
				try encode(to: &container, array: value)
			} else if let value = value as? [String: Any] {
				var container = container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
				try encode(to: &container, dictionary: value)
			} else {
				throw encodingError(forValue: value, codingPath: container.codingPath)
			}
		}
	}
	
	static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
		if let value = value as? Bool {
			try container.encode(value)
		} else if let value = value as? Int64 {
			try container.encode(value)
		} else if let value = value as? Double {
			try container.encode(value)
		} else if let value = value as? String {
			try container.encode(value)
		} else if value is JSONNull {
			try container.encodeNil()
		} else {
			throw encodingError(forValue: value, codingPath: container.codingPath)
		}
	}
	
	public required init(from decoder: Decoder) throws {
		if var arrayContainer = try? decoder.unkeyedContainer() {
			self.value = try JSONAny.decodeArray(from: &arrayContainer)
		} else if var container = try? decoder.container(keyedBy: JSONCodingKey.self) {
			self.value = try JSONAny.decodeDictionary(from: &container)
		} else {
			let container = try decoder.singleValueContainer()
			self.value = try JSONAny.decode(from: container)
		}
	}
	
	public func encode(to encoder: Encoder) throws {
		if let arr = self.value as? [Any] {
			var container = encoder.unkeyedContainer()
			try JSONAny.encode(to: &container, array: arr)
		} else if let dict = self.value as? [String: Any] {
			var container = encoder.container(keyedBy: JSONCodingKey.self)
			try JSONAny.encode(to: &container, dictionary: dict)
		} else {
			var container = encoder.singleValueContainer()
			try JSONAny.encode(to: &container, value: self.value)
		}
	}
}

var data = "{\"Case\":{\"actions\":null,\"fieldItems\":[{\"editableForNew\":true,\"editableForUpdate\":true,\"label\":\"Subject\",\"layoutComponents\":[{\"details\":{\"aggregatable\":true,\"aiPredictionField\":false,\"autoNumber\":false,\"byteLength\":765,\"calculated\":false,\"calculatedFormula\":null,\"cascadeDelete\":false,\"caseSensitive\":false,\"compoundFieldName\":null,\"controllerName\":null,\"createable\":true,\"custom\":false,\"defaultValue\":null,\"defaultValueFormula\":null,\"defaultedOnCreate\":false,\"dependentPicklist\":false,\"deprecatedAndHidden\":false,\"digits\":0,\"displayLocationInDecimal\":false,\"encrypted\":false,\"externalId\":false,\"extraTypeInfo\":null,\"filterable\":true,\"filteredLookupInfo\":null,\"formulaTreatNullNumberAsZero\":false,\"groupable\":true,\"highScaleNumber\":false,\"htmlFormatted\":false,\"idLookup\":false,\"inlineHelpText\":null,\"label\":\"Subject\",\"length\":255,\"mask\":null,\"maskType\":null,\"name\":\"Subject\",\"nameField\":false,\"namePointing\":false,\"nillable\":true,\"permissionable\":true,\"picklistValues\":null,\"polymorphicForeignKey\":false,\"precision\":0,\"queryByDistance\":false,\"referenceTargetField\":null,\"referenceTo\":[],\"relationshipName\":null,\"relationshipOrder\":null,\"restrictedDelete\":false,\"restrictedPicklist\":false,\"scale\":0,\"searchPrefilterable\":false,\"soapType\":\"xsd:string\",\"sortable\":true,\"type\":\"string\",\"unique\":false,\"updateable\":true,\"writeRequiresMasterRead\":false},\"displayLines\":1,\"tabOrder\":1,\"type\":\"Field\",\"value\":\"Subject\"}],\"placeholder\":false,\"required\":false},{\"editableForNew\":true,\"editableForUpdate\":true,\"label\":\"Priority\",\"layoutComponents\":[{\"details\":{\"aggregatable\":true,\"aiPredictionField\":false,\"autoNumber\":false,\"byteLength\":120,\"calculated\":false,\"calculatedFormula\":null,\"cascadeDelete\":false,\"caseSensitive\":false,\"compoundFieldName\":null,\"controllerName\":null,\"createable\":true,\"custom\":false,\"defaultValue\":null,\"defaultValueFormula\":null,\"defaultedOnCreate\":false,\"dependentPicklist\":false,\"deprecatedAndHidden\":false,\"digits\":0,\"displayLocationInDecimal\":false,\"encrypted\":false,\"externalId\":false,\"extraTypeInfo\":null,\"filterable\":true,\"filteredLookupInfo\":null,\"formulaTreatNullNumberAsZero\":false,\"groupable\":true,\"highScaleNumber\":false,\"htmlFormatted\":false,\"idLookup\":false,\"inlineHelpText\":null,\"label\":\"Priority\",\"length\":40,\"mask\":null,\"maskType\":null,\"name\":\"Priority\",\"nameField\":false,\"namePointing\":false,\"nillable\":true,\"permissionable\":true,\"picklistValues\":null,\"polymorphicForeignKey\":false,\"precision\":0,\"queryByDistance\":false,\"referenceTargetField\":null,\"referenceTo\":[],\"relationshipName\":null,\"relationshipOrder\":null,\"restrictedDelete\":false,\"restrictedPicklist\":false,\"scale\":0,\"searchPrefilterable\":false,\"soapType\":\"xsd:string\",\"sortable\":true,\"type\":\"picklist\",\"unique\":false,\"updateable\":true,\"writeRequiresMasterRead\":false},\"displayLines\":1,\"tabOrder\":2,\"type\":\"Field\",\"value\":\"Priority\"}],\"placeholder\":false,\"required\":false},{\"editableForNew\":true,\"editableForUpdate\":true,\"label\":\"Status\",\"layoutComponents\":[{\"details\":{\"aggregatable\":true,\"aiPredictionField\":false,\"autoNumber\":false,\"byteLength\":120,\"calculated\":false,\"calculatedFormula\":null,\"cascadeDelete\":false,\"caseSensitive\":false,\"compoundFieldName\":null,\"controllerName\":null,\"createable\":true,\"custom\":false,\"defaultValue\":null,\"defaultValueFormula\":null,\"defaultedOnCreate\":true,\"dependentPicklist\":false,\"deprecatedAndHidden\":false,\"digits\":0,\"displayLocationInDecimal\":false,\"encrypted\":false,\"externalId\":false,\"extraTypeInfo\":null,\"filterable\":true,\"filteredLookupInfo\":null,\"formulaTreatNullNumberAsZero\":false,\"groupable\":true,\"highScaleNumber\":false,\"htmlFormatted\":false,\"idLookup\":false,\"inlineHelpText\":null,\"label\":\"Status\",\"length\":40,\"mask\":null,\"maskType\":null,\"name\":\"Status\",\"nameField\":false,\"namePointing\":false,\"nillable\":true,\"permissionable\":false,\"picklistValues\":null,\"polymorphicForeignKey\":false,\"precision\":0,\"queryByDistance\":false,\"referenceTargetField\":null,\"referenceTo\":[],\"relationshipName\":null,\"relationshipOrder\":null,\"restrictedDelete\":false,\"restrictedPicklist\":false,\"scale\":0,\"searchPrefilterable\":false,\"soapType\":\"xsd:string\",\"sortable\":true,\"type\":\"picklist\",\"unique\":false,\"updateable\":true,\"writeRequiresMasterRead\":false},\"displayLines\":1,\"tabOrder\":3,\"type\":\"Field\",\"value\":\"Status\"}],\"placeholder\":false,\"required\":false},{\"editableForNew\":false,\"editableForUpdate\":false,\"label\":\"Case Number\",\"layoutComponents\":[{\"details\":{\"aggregatable\":true,\"aiPredictionField\":false,\"autoNumber\":true,\"byteLength\":90,\"calculated\":false,\"calculatedFormula\":null,\"cascadeDelete\":false,\"caseSensitive\":false,\"compoundFieldName\":null,\"controllerName\":null,\"createable\":false,\"custom\":false,\"defaultValue\":null,\"defaultValueFormula\":null,\"defaultedOnCreate\":true,\"dependentPicklist\":false,\"deprecatedAndHidden\":false,\"digits\":0,\"displayLocationInDecimal\":false,\"encrypted\":false,\"externalId\":false,\"extraTypeInfo\":null,\"filterable\":true,\"filteredLookupInfo\":null,\"formulaTreatNullNumberAsZero\":false,\"groupable\":false,\"highScaleNumber\":false,\"htmlFormatted\":false,\"idLookup\":true,\"inlineHelpText\":null,\"label\":\"Case Number\",\"length\":30,\"mask\":null,\"maskType\":null,\"name\":\"CaseNumber\",\"nameField\":true,\"namePointing\":false,\"nillable\":false,\"permissionable\":false,\"picklistValues\":null,\"polymorphicForeignKey\":false,\"precision\":0,\"queryByDistance\":false,\"referenceTargetField\":null,\"referenceTo\":[],\"relationshipName\":null,\"relationshipOrder\":null,\"restrictedDelete\":false,\"restrictedPicklist\":false,\"scale\":0,\"searchPrefilterable\":false,\"soapType\":\"xsd:string\",\"sortable\":true,\"type\":\"string\",\"unique\":false,\"updateable\":false,\"writeRequiresMasterRead\":false},\"displayLines\":1,\"tabOrder\":4,\"type\":\"Field\",\"value\":\"CaseNumber\"}],\"placeholder\":false,\"required\":false},{\"editableForNew\":true,\"editableForUpdate\":true,\"label\":\"Case Origin\",\"layoutComponents\":[{\"details\":{\"aggregatable\":true,\"aiPredictionField\":false,\"autoNumber\":false,\"byteLength\":120,\"calculated\":false,\"calculatedFormula\":null,\"cascadeDelete\":false,\"caseSensitive\":false,\"compoundFieldName\":null,\"controllerName\":null,\"createable\":true,\"custom\":false,\"defaultValue\":null,\"defaultValueFormula\":null,\"defaultedOnCreate\":false,\"dependentPicklist\":false,\"deprecatedAndHidden\":false,\"digits\":0,\"displayLocationInDecimal\":false,\"encrypted\":false,\"externalId\":false,\"extraTypeInfo\":null,\"filterable\":true,\"filteredLookupInfo\":null,\"formulaTreatNullNumberAsZero\":false,\"groupable\":true,\"highScaleNumber\":false,\"htmlFormatted\":false,\"idLookup\":false,\"inlineHelpText\":null,\"label\":\"Case Origin\",\"length\":40,\"mask\":null,\"maskType\":null,\"name\":\"Origin\",\"nameField\":false,\"namePointing\":false,\"nillable\":true,\"permissionable\":true,\"picklistValues\":null,\"polymorphicForeignKey\":false,\"precision\":0,\"queryByDistance\":false,\"referenceTargetField\":null,\"referenceTo\":[],\"relationshipName\":null,\"relationshipOrder\":null,\"restrictedDelete\":false,\"restrictedPicklist\":false,\"scale\":0,\"searchPrefilterable\":false,\"soapType\":\"xsd:string\",\"sortable\":true,\"type\":\"picklist\",\"unique\":false,\"updateable\":true,\"writeRequiresMasterRead\":false},\"displayLines\":1,\"tabOrder\":5,\"type\":\"Field\",\"value\":\"Origin\"}],\"placeholder\":false,\"required\":false}],\"id\":\"0AH1U0000001NxQWAU\",\"imageItems\":null,\"label\":\"mobile\",\"name\":\"mobile\",\"objectType\":\"Case\"}}"


var layoutData = try? JSONDecoder().decode(CaseCompactLayout.self, from: data.data(using: .utf8)!)
for field in (layoutData?.caseCompactLayoutCase.fieldItems)! {
	print(field.layoutComponents.first?.value)
}

let x = layoutData?.caseCompactLayoutCase.fieldItems.map({ (fieldItem) -> String in
	return (fieldItem.layoutComponents.first?.value)!
})


if let y = layoutData?.caseCompactLayoutCase.fieldItems.map({ (fieldItem) -> String in return (fieldItem.layoutComponents.first?.value)!}) {
print(y)
}

let foo = "{\"Case\":{\"actions\":null,\"fieldItems\":[{\"editableForNew\":true,\"editableForUpdate\":true,\"label\":\"Subject\",\"layoutComponents\":[{\"details\":{\"aggregatable\":true,\"aiPredictionField\":false,\"autoNumber\":false,\"byteLength\":765,\"calculated\":false,\"calculatedFormula\":null,\"cascadeDelete\":false,\"caseSensitive\":false,\"compoundFieldName\":null,\"controllerName\":null,\"createable\":true,\"custom\":false,\"defaultValue\":null,\"defaultValueFormula\":null,\"defaultedOnCreate\":false,\"dependentPicklist\":false,\"deprecatedAndHidden\":false,\"digits\":0,\"displayLocationInDecimal\":false,\"encrypted\":false,\"externalId\":false,\"extraTypeInfo\":null,\"filterable\":true,\"filteredLookupInfo\":null,\"formulaTreatNullNumberAsZero\":false,\"groupable\":true,\"highScaleNumber\":false,\"htmlFormatted\":false,\"idLookup\":false,\"inlineHelpText\":null,\"label\":\"Subject\",\"length\":255,\"mask\":null,\"maskType\":null,\"name\":\"Subject\",\"nameField\":false,\"namePointing\":false,\"nillable\":true,\"permissionable\":true,\"picklistValues\":null,\"polymorphicForeignKey\":false,\"precision\":0,\"queryByDistance\":false,\"referenceTargetField\":null,\"referenceTo\":[],\"relationshipName\":null,\"relationshipOrder\":null,\"restrictedDelete\":false,\"restrictedPicklist\":false,\"scale\":0,\"searchPrefilterable\":false,\"soapType\":\"xsd:string\",\"sortable\":true,\"type\":\"string\",\"unique\":false,\"updateable\":true,\"writeRequiresMasterRead\":false},\"displayLines\":1,\"tabOrder\":1,\"type\":\"Field\",\"value\":\"Subject\"}],\"placeholder\":false,\"required\":false},{\"editableForNew\":true,\"editableForUpdate\":true,\"label\":\"Priority\",\"layoutComponents\":[{\"details\":{\"aggregatable\":true,\"aiPredictionField\":false,\"autoNumber\":false,\"byteLength\":120,\"calculated\":false,\"calculatedFormula\":null,\"cascadeDelete\":false,\"caseSensitive\":false,\"compoundFieldName\":null,\"controllerName\":null,\"createable\":true,\"custom\":false,\"defaultValue\":null,\"defaultValueFormula\":null,\"defaultedOnCreate\":false,\"dependentPicklist\":false,\"deprecatedAndHidden\":false,\"digits\":0,\"displayLocationInDecimal\":false,\"encrypted\":false,\"externalId\":false,\"extraTypeInfo\":null,\"filterable\":true,\"filteredLookupInfo\":null,\"formulaTreatNullNumberAsZero\":false,\"groupable\":true,\"highScaleNumber\":false,\"htmlFormatted\":false,\"idLookup\":false,\"inlineHelpText\":null,\"label\":\"Priority\",\"length\":40,\"mask\":null,\"maskType\":null,\"name\":\"Priority\",\"nameField\":false,\"namePointing\":false,\"nillable\":true,\"permissionable\":true,\"picklistValues\":null,\"polymorphicForeignKey\":false,\"precision\":0,\"queryByDistance\":false,\"referenceTargetField\":null,\"referenceTo\":[],\"relationshipName\":null,\"relationshipOrder\":null,\"restrictedDelete\":false,\"restrictedPicklist\":false,\"scale\":0,\"searchPrefilterable\":false,\"soapType\":\"xsd:string\",\"sortable\":true,\"type\":\"picklist\",\"unique\":false,\"updateable\":true,\"writeRequiresMasterRead\":false},\"displayLines\":1,\"tabOrder\":2,\"type\":\"Field\",\"value\":\"Priority\"}],\"placeholder\":false,\"required\":false},{\"editableForNew\":true,\"editableForUpdate\":true,\"label\":\"Status\",\"layoutComponents\":[{\"details\":{\"aggregatable\":true,\"aiPredictionField\":false,\"autoNumber\":false,\"byteLength\":120,\"calculated\":false,\"calculatedFormula\":null,\"cascadeDelete\":false,\"caseSensitive\":false,\"compoundFieldName\":null,\"controllerName\":null,\"createable\":true,\"custom\":false,\"defaultValue\":null,\"defaultValueFormula\":null,\"defaultedOnCreate\":true,\"dependentPicklist\":false,\"deprecatedAndHidden\":false,\"digits\":0,\"displayLocationInDecimal\":false,\"encrypted\":false,\"externalId\":false,\"extraTypeInfo\":null,\"filterable\":true,\"filteredLookupInfo\":null,\"formulaTreatNullNumberAsZero\":false,\"groupable\":true,\"highScaleNumber\":false,\"htmlFormatted\":false,\"idLookup\":false,\"inlineHelpText\":null,\"label\":\"Status\",\"length\":40,\"mask\":null,\"maskType\":null,\"name\":\"Status\",\"nameField\":false,\"namePointing\":false,\"nillable\":true,\"permissionable\":false,\"picklistValues\":null,\"polymorphicForeignKey\":false,\"precision\":0,\"queryByDistance\":false,\"referenceTargetField\":null,\"referenceTo\":[],\"relationshipName\":null,\"relationshipOrder\":null,\"restrictedDelete\":false,\"restrictedPicklist\":false,\"scale\":0,\"searchPrefilterable\":false,\"soapType\":\"xsd:string\",\"sortable\":true,\"type\":\"picklist\",\"unique\":false,\"updateable\":true,\"writeRequiresMasterRead\":false},\"displayLines\":1,\"tabOrder\":3,\"type\":\"Field\",\"value\":\"Status\"}],\"placeholder\":false,\"required\":false},{\"editableForNew\":false,\"editableForUpdate\":false,\"label\":\"Case Number\",\"layoutComponents\":[{\"details\":{\"aggregatable\":true,\"aiPredictionField\":false,\"autoNumber\":true,\"byteLength\":90,\"calculated\":false,\"calculatedFormula\":null,\"cascadeDelete\":false,\"caseSensitive\":false,\"compoundFieldName\":null,\"controllerName\":null,\"createable\":false,\"custom\":false,\"defaultValue\":null,\"defaultValueFormula\":null,\"defaultedOnCreate\":true,\"dependentPicklist\":false,\"deprecatedAndHidden\":false,\"digits\":0,\"displayLocationInDecimal\":false,\"encrypted\":false,\"externalId\":false,\"extraTypeInfo\":null,\"filterable\":true,\"filteredLookupInfo\":null,\"formulaTreatNullNumberAsZero\":false,\"groupable\":false,\"highScaleNumber\":false,\"htmlFormatted\":false,\"idLookup\":true,\"inlineHelpText\":null,\"label\":\"Case Number\",\"length\":30,\"mask\":null,\"maskType\":null,\"name\":\"CaseNumber\",\"nameField\":true,\"namePointing\":false,\"nillable\":false,\"permissionable\":false,\"picklistValues\":null,\"polymorphicForeignKey\":false,\"precision\":0,\"queryByDistance\":false,\"referenceTargetField\":null,\"referenceTo\":[],\"relationshipName\":null,\"relationshipOrder\":null,\"restrictedDelete\":false,\"restrictedPicklist\":false,\"scale\":0,\"searchPrefilterable\":false,\"soapType\":\"xsd:string\",\"sortable\":true,\"type\":\"string\",\"unique\":false,\"updateable\":false,\"writeRequiresMasterRead\":false},\"displayLines\":1,\"tabOrder\":4,\"type\":\"Field\",\"value\":\"CaseNumber\"}],\"placeholder\":false,\"required\":false},{\"editableForNew\":true,\"editableForUpdate\":true,\"label\":\"Case Origin\",\"layoutComponents\":[{\"details\":{\"aggregatable\":true,\"aiPredictionField\":false,\"autoNumber\":false,\"byteLength\":120,\"calculated\":false,\"calculatedFormula\":null,\"cascadeDelete\":false,\"caseSensitive\":false,\"compoundFieldName\":null,\"controllerName\":null,\"createable\":true,\"custom\":false,\"defaultValue\":null,\"defaultValueFormula\":null,\"defaultedOnCreate\":false,\"dependentPicklist\":false,\"deprecatedAndHidden\":false,\"digits\":0,\"displayLocationInDecimal\":false,\"encrypted\":false,\"externalId\":false,\"extraTypeInfo\":null,\"filterable\":true,\"filteredLookupInfo\":null,\"formulaTreatNullNumberAsZero\":false,\"groupable\":true,\"highScaleNumber\":false,\"htmlFormatted\":false,\"idLookup\":false,\"inlineHelpText\":null,\"label\":\"Case Origin\",\"length\":40,\"mask\":null,\"maskType\":null,\"name\":\"Origin\",\"nameField\":false,\"namePointing\":false,\"nillable\":true,\"permissionable\":true,\"picklistValues\":null,\"polymorphicForeignKey\":false,\"precision\":0,\"queryByDistance\":false,\"referenceTargetField\":null,\"referenceTo\":[],\"relationshipName\":null,\"relationshipOrder\":null,\"restrictedDelete\":false,\"restrictedPicklist\":false,\"scale\":0,\"searchPrefilterable\":false,\"soapType\":\"xsd:string\",\"sortable\":true,\"type\":\"picklist\",\"unique\":false,\"updateable\":true,\"writeRequiresMasterRead\":false},\"displayLines\":1,\"tabOrder\":5,\"type\":\"Field\",\"value\":\"Origin\"}],\"placeholder\":false,\"required\":false},{\"editableForNew\":true,\"editableForUpdate\":true,\"label\":\"Account Name\",\"layoutComponents\":[{\"details\":{\"aggregatable\":true,\"aiPredictionField\":false,\"autoNumber\":false,\"byteLength\":18,\"calculated\":false,\"calculatedFormula\":null,\"cascadeDelete\":false,\"caseSensitive\":false,\"compoundFieldName\":null,\"controllerName\":null,\"createable\":true,\"custom\":false,\"defaultValue\":null,\"defaultValueFormula\":null,\"defaultedOnCreate\":false,\"dependentPicklist\":false,\"deprecatedAndHidden\":false,\"digits\":0,\"displayLocationInDecimal\":false,\"encrypted\":false,\"externalId\":false,\"extraTypeInfo\":null,\"filterable\":true,\"filteredLookupInfo\":null,\"formulaTreatNullNumberAsZero\":false,\"groupable\":true,\"highScaleNumber\":false,\"htmlFormatted\":false,\"idLookup\":false,\"inlineHelpText\":null,\"label\":\"Account ID\",\"length\":18,\"mask\":null,\"maskType\":null,\"name\":\"AccountId\",\"nameField\":false,\"namePointing\":false,\"nillable\":true,\"permissionable\":true,\"picklistValues\":null,\"polymorphicForeignKey\":false,\"precision\":0,\"queryByDistance\":false,\"referenceTargetField\":null,\"referenceTo\":[\"Account\"],\"relationshipName\":\"Account\",\"relationshipOrder\":null,\"restrictedDelete\":false,\"restrictedPicklist\":false,\"scale\":0,\"searchPrefilterable\":true,\"soapType\":\"tns:ID\",\"sortable\":true,\"type\":\"reference\",\"unique\":false,\"updateable\":true,\"writeRequiresMasterRead\":false},\"displayLines\":1,\"tabOrder\":6,\"type\":\"Field\",\"value\":\"AccountId\"}],\"placeholder\":false,\"required\":false},{\"editableForNew\":true,\"editableForUpdate\":true,\"label\":\"Contact Name\",\"layoutComponents\":[{\"details\":{\"aggregatable\":true,\"aiPredictionField\":false,\"autoNumber\":false,\"byteLength\":18,\"calculated\":false,\"calculatedFormula\":null,\"cascadeDelete\":false,\"caseSensitive\":false,\"compoundFieldName\":null,\"controllerName\":null,\"createable\":true,\"custom\":false,\"defaultValue\":null,\"defaultValueFormula\":null,\"defaultedOnCreate\":false,\"dependentPicklist\":false,\"deprecatedAndHidden\":false,\"digits\":0,\"displayLocationInDecimal\":false,\"encrypted\":false,\"externalId\":false,\"extraTypeInfo\":null,\"filterable\":true,\"filteredLookupInfo\":null,\"formulaTreatNullNumberAsZero\":false,\"groupable\":true,\"highScaleNumber\":false,\"htmlFormatted\":false,\"idLookup\":false,\"inlineHelpText\":null,\"label\":\"Contact ID\",\"length\":18,\"mask\":null,\"maskType\":null,\"name\":\"ContactId\",\"nameField\":false,\"namePointing\":false,\"nillable\":true,\"permissionable\":true,\"picklistValues\":null,\"polymorphicForeignKey\":false,\"precision\":0,\"queryByDistance\":false,\"referenceTargetField\":null,\"referenceTo\":[\"Contact\"],\"relationshipName\":\"Contact\",\"relationshipOrder\":null,\"restrictedDelete\":false,\"restrictedPicklist\":false,\"scale\":0,\"searchPrefilterable\":true,\"soapType\":\"tns:ID\",\"sortable\":true,\"type\":\"reference\",\"unique\":false,\"updateable\":true,\"writeRequiresMasterRead\":false},\"displayLines\":1,\"tabOrder\":7,\"type\":\"Field\",\"value\":\"ContactId\"}],\"placeholder\":false,\"required\":false}],\"id\":\"0AH1U0000001NxQWAU\",\"imageItems\":null,\"label\":\"mobile\",\"name\":\"mobile\",\"objectType\":\"Case\"}}"


if let layoutData = try? JSONDecoder().decode(CaseCompactLayout.self, from: foo.data(using: .utf8)!){
	let y = layoutData.caseCompactLayoutCase.fieldItems.map({ (fieldItem) -> String in return (fieldItem.layoutComponents.first?.value)!})
	print(type(of: y))
	print(y)
	
}

var c = "00001026"
print(Int(c))
