library(htmltools)
library(yaml)

# carousel displays a list of items w/ nav buttons
carousel <- function(id, duration, items) {
  index <- -1
  items <- lapply(items, function(item) {
    index <<- index + 1
    carouselItem(item$caption, item$image, item$link, index, duration)
  })

  js <- tags$script(HTML(sprintf(
    "
(function () {
  function init() {
    var carousel = document.getElementById('%1$s');
    if (!carousel) return;
    carousel.addEventListener('slide.bs.carousel', function (e) {
      var card = document.getElementById('%1$s-card');
      card.querySelectorAll('.site-carousel-cap').forEach(function (el, i) {
        el.classList.toggle('active', i === e.to);
      });
      card.querySelectorAll('.site-carousel-dot').forEach(function (el, i) {
        el.classList.toggle('active', i === e.to);
      });
    });
  }
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
",
    id
  )))

  captions <- tagList(lapply(seq_along(items), function(i) {
    tags$p(
      class = paste0("site-carousel-cap", if (i == 1) " active" else ""),
      items[[i]]$caption
    )
  }))

  dots <- tagList(lapply(seq_along(items), function(i) {
    btn <- tags$button(
      class = paste0("site-carousel-dot", if (i == 1) " active" else ""),
      type = "button",
      `data-bs-target` = paste0("#", id),
      `data-bs-slide-to` = as.character(i - 1),
      `aria-label` = paste("Slide", i)
    )
    if (i == 1) {
      btn <- tagAppendAttributes(btn, `aria-current` = "true")
    }
    btn
  }))

  # Styles live in styles/html/custom.scss (.site-carousel)
  div(
    id = paste0(id, "-card"),
    class = "site-carousel",
    js,
    div(
      id = id,
      class = "carousel slide",
      `data-bs-ride` = "carousel",
      div(
        class = "carousel-inner",
        tagList(lapply(items, function(item) item$item))
      ),
      navButton(id, "prev", "Previous"),
      navButton(id, "next", "Next")
    ),
    div(
      class = "site-carousel-footer",
      captions,
      div(class = "site-carousel-dots", dots)
    )
  )
}

# carousel item
carouselItem <- function(caption, image, link, index, interval) {
  item <- div(
    class = paste0("carousel-item", if (index == 0) " active" else ""),
    `data-bs-interval` = interval,
    a(
      href = link,
      img(src = image, class = "carousel-img", alt = caption)
    )
  )
  list(caption = caption, item = item)
}

# nav button
navButton <- function(targetId, type, text) {
  tags$button(
    class = paste0("carousel-control-", type),
    type = "button",
    `data-bs-target` = paste0("#", targetId),
    `data-bs-slide` = type,
    span(
      class = paste0("carousel-control-", type, "-icon"),
      `aria-hidden` = "true"
    ),
    span(class = "visually-hidden", text)
  )
}
