import { useState, useEffect } from 'react'
import * as fcl from '@onflow/fcl'

fcl.config()
  .put('accessNode.api', 'https://rest-testnet.onflow.org')
  .put('discovery.wallet', 'https://fcl-discovery.onflow.org/testnet/authn')

export default function Home() {
  const [user, setUser] = useState(null)
  const [videoUrl, setVideoUrl] = useState('')

  useEffect(() => {
    fcl.currentUser().subscribe(setUser)
  }, [])

  const submitReview = async () => {
    try {
      const transactionId = await fcl.mutate({
        cadence: `
          import DevdockReviews from 0x9d2ade18cb6bea1a

          transaction(videoUrl: String) {
            prepare(signer: AuthAccount) {
              if signer.borrow<&DevdockReviews.ReviewCollection>(from: /storage/ReviewCollection) == nil {
                signer.save(<-DevdockReviews.createReviewCollection(), to: /storage/ReviewCollection)
              }

              let collection = signer.borrow<&DevdockReviews.ReviewCollection>(from: /storage/ReviewCollection)
                ?? panic("Could not borrow collection")

              collection.submitReview(videoUrl: videoUrl)
            }
          }
        `,
        args: (arg, t) => [arg(videoUrl, t.String)],
        payer: fcl.authz,
        proposer: fcl.authz,
        authorizations: [fcl.authz],
        limit: 999
      })

      console.log('Review submitted:', transactionId)
      alert('Review submitted successfully!')
    } catch (error) {
      console.error('Error submitting review:', error)
      alert('Error submitting review')
    }
  }

  return (
    <div className='container mx-auto p-4'>
      <h1 className='text-3xl font-bold mb-4'>Devdock Review Submission</h1>
      
      {!user?.addr ? (
        <button
          onClick={fcl.logIn}
          className='bg-blue-500 text-white px-4 py-2 rounded'
        >
          Connect Wallet
        </button>
      ) : (
        <div>
          <p className='mb-4'>Connected: {user?.addr}</p>
          <div className='mb-4'>
            <input
              type='text'
              placeholder='Enter YouTube video URL'
              value={videoUrl}
              onChange={(e) => setVideoUrl(e.target.value)}
              className='w-full p-2 border rounded'
            />
          </div>
          <button
            onClick={submitReview}
            className='bg-green-500 text-white px-4 py-2 rounded'
          >
            Submit Review
          </button>
        </div>
      )}
    </div>
  )
}