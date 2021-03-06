//
//  CommentsPresenter.swift
//  EssentialFeed
//
//  Created by Robert Dates on 1/23/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public final class CommentsPresenter {
	private let commentView: CommentView
	private let errorView: CommentErrorView
	private let loadingView: CommentLoadingView
	private let currentDate: () -> Date
	
	private let dateFormatter = RelativeDateTimeFormatter()

	public init(commentView: CommentView, loadingView: CommentLoadingView, errorView: CommentErrorView,
				currentDate: @escaping () -> Date = Date.init,
		  locale: Locale = Locale.current) {
		self.commentView = commentView
		self.loadingView = loadingView
		self.errorView = errorView
		self.currentDate = currentDate
		dateFormatter.locale = locale
	}
	
	public static var title: String {
		return NSLocalizedString("COMMENTS_VIEW_TITLE",
			tableName: "Comments",
			bundle: Bundle(for: CommentsPresenter.self),
			comment: "Title for Comment View")
	}
	
	private var commentLoadError: String {
		return NSLocalizedString("COMMENTS_VIEW_CONNECTION_ERROR",
			 tableName: "Comments",
			 bundle: Bundle(for: CommentsPresenter.self),
			 comment: "Error message displayed when we can't load the comments from the server")
	}
	
	public func didStartLoadingComments() {
		errorView.display(.noError)
		loadingView.display(CommentLoadingViewModel(isLoading: true))
	}
	
	public func didFinishLoadingComments(with comments: [Comment]) {
		commentView.display(CommentViewModel(comments: createPresentables(from: comments)))
		loadingView.display(CommentLoadingViewModel(isLoading: false))
	}
	
	public func didFinishLoadingComments(with error: Error) {
		errorView.display(.error(message: commentLoadError))
		loadingView.display(CommentLoadingViewModel(isLoading: false))
	}
	
	private func createPresentables(from comments: [Comment]) -> [PresentableComment] {
		return comments.compactMap {
			PresentableComment(username: $0.author.username, message: $0.message, date: format($0.createdAt))
		}
	}
	
	private func format(_ date: Date) -> String {
		return dateFormatter.localizedString(for: date, relativeTo: currentDate())
	}
}
