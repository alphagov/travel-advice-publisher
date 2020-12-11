describe('Travel advice utilities', function () {
  'use strict'

  describe('convert titles to slugs', function () {
    it('converts to lowercase', function () {
      expect(TravelAdviceUtils.convertToSlug('THING')).toBe('thing')
    })

    it('converts spaces to hyphens', function () {
      expect(TravelAdviceUtils.convertToSlug('The Snail and the Slug'))
        .toBe('the-snail-and-the-slug')
    })

    it('strips out non-word characters', function () {
      expect(TravelAdviceUtils.convertToSlug('The Slug\'s trail of destruction:'))
        .toBe('the-slugs-trail-of-destruction')
    })
  })
})
