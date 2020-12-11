window.TravelAdviceUtils = {
  convertToSlug: function (title) {
    return title.toLowerCase().replace(/[^\w ]+/g, '').replace(/ +/g, '-')
  }
}
