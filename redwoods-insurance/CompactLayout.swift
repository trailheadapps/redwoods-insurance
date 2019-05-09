import Foundation

// This lightweight data model is used by `ObjectLayoutDataSource` to retrieve
// the list of fields for a given object type.

struct CompactLayout: Codable {
	var fieldItems: [FieldItem]
}

extension CompactLayout {
	struct FieldItem: Codable {
		var layoutComponents: [LayoutComponent]
	}
}

extension CompactLayout {
	struct LayoutComponent: Codable {
		var value: String
	}
}
