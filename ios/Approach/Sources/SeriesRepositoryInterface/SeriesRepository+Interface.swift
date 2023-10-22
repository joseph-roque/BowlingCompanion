import Dependencies
import ModelsLibrary

extension Series {
	public enum Ordering: Hashable, CaseIterable {
		case newestFirst
		case oldestFirst
		case lowestToHighest
		case highestToLowest
	}
}

public struct SeriesRepository: Sendable {
	public var list: @Sendable (League.ID, Series.Ordering) -> AsyncThrowingStream<[Series.List], Error>
	public var summaries: @Sendable (League.ID) -> AsyncThrowingStream<[Series.Summary], Error>
	public var archived: @Sendable () -> AsyncThrowingStream<[Series.Archived], Error>
	public var edit: @Sendable (Series.ID) async throws -> Series.Edit
	public var create: @Sendable (Series.Create) async throws -> Void
	public var update: @Sendable (Series.Edit) async throws -> Void
	public var archive: @Sendable (Series.ID) async throws -> Void
	public var unarchive: @Sendable (Series.ID) async throws -> Void

	public init(
		list: @escaping @Sendable (League.ID, Series.Ordering) -> AsyncThrowingStream<[Series.List], Error>,
		summaries: @escaping @Sendable (League.ID) -> AsyncThrowingStream<[Series.Summary], Error>,
		archived: @escaping @Sendable () -> AsyncThrowingStream<[Series.Archived], Error>,
		edit: @escaping @Sendable (Series.ID) async throws -> Series.Edit,
		create: @escaping @Sendable (Series.Create) async throws -> Void,
		update: @escaping @Sendable (Series.Edit) async throws -> Void,
		archive: @escaping @Sendable (Series.ID) async throws -> Void,
		unarchive: @escaping @Sendable (Series.ID) async throws -> Void
	) {
		self.list = list
		self.summaries = summaries
		self.archived = archived
		self.edit = edit
		self.create = create
		self.update = update
		self.archive = archive
		self.unarchive = unarchive
	}

	public func list(bowledIn: League.ID, orderedBy: Series.Ordering) -> AsyncThrowingStream<[Series.List], Error> {
		self.list(bowledIn, orderedBy)
	}

	public func summaries(bowledIn: League.ID) -> AsyncThrowingStream<[Series.Summary], Error> {
		self.summaries(bowledIn)
	}
}

extension SeriesRepository: TestDependencyKey {
	public static var testValue = Self(
		list: { _, _ in unimplemented("\(Self.self).list") },
		summaries: { _ in unimplemented("\(Self.self).summaries") },
		archived: { unimplemented("\(Self.self).archived") },
		edit: { _ in unimplemented("\(Self.self).edit") },
		create: { _ in unimplemented("\(Self.self).create") },
		update: { _ in unimplemented("\(Self.self).update") },
		archive: { _ in unimplemented("\(Self.self).archive") },
		unarchive: { _ in unimplemented("\(Self.self).unarchive") }
	)
}

extension DependencyValues {
	public var series: SeriesRepository {
		get { self[SeriesRepository.self] }
		set { self[SeriesRepository.self] = newValue }
	}
}
