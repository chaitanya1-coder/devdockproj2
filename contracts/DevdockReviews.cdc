access(all) contract DevdockReviews {
    access(all) event ReviewSubmitted(id: UInt64, reviewer: Address, videoUrl: String, points: UInt64)
    
    access(all) resource Review {
        access(all) let id: UInt64
        access(all) let reviewer: Address
        access(all) let videoUrl: String
        access(all) let timestamp: UFix64
        access(all) let points: UInt64

        init(id: UInt64, reviewer: Address, videoUrl: String, points: UInt64) {
            self.id = id
            self.reviewer = reviewer
            self.videoUrl = videoUrl
            self.timestamp = getCurrentBlock().timestamp
            self.points = points
        }
    }

    access(all) resource interface ReviewCollectionPublic {
        access(all) fun getReviews(): [Review]
        access(all) fun submitReview(videoUrl: String)
    }

    access(all) resource ReviewCollection: ReviewCollectionPublic {
        access(all) var reviews: @{UInt64: Review}
        access(all) var nextReviewId: UInt64

        init() {
            self.reviews <- {}
            self.nextReviewId = 1
        }

        access(all) fun submitReview(videoUrl: String) {
            let review <- create Review(
                id: self.nextReviewId,
                reviewer: self.owner?.address!,
                videoUrl: videoUrl,
                points: 2000
            )
            
            emit ReviewSubmitted(
                id: review.id,
                reviewer: review.reviewer,
                videoUrl: review.videoUrl,
                points: review.points
            )

            self.reviews[self.nextReviewId] <-! review
            self.nextReviewId = self.nextReviewId + 1
        }

        access(all) fun getReviews(): [Review] {
            return self.reviews.values
        }

        destroy() {
            destroy self.reviews
        }
    }

    access(all) fun createReviewCollection(): @ReviewCollection {
        return <- create ReviewCollection()
    }
}