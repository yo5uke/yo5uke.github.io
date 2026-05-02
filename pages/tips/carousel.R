library(htmltools)
library(yaml)

# carousel displays a list of items w/ nav buttons
carousel <- function(id, duration, items) {
  index <- -1
  items <- lapply(items, function(item) {
    index <<- index + 1
    carouselItem(item$caption, item$image, item$link, index, duration)
  })

  css <- tags$style(HTML(sprintf(
    "
#%1$s-card {
  max-width: 780px;
  margin: 0 auto;
  padding: 0 60px;
}
#%1$s {
  box-shadow: 0 2px 20px rgba(0, 0, 0, 0.09);
  border-radius: 12px;
}
#%1$s .carousel-inner {
  border-radius: 12px;
  overflow: hidden;
}
#%1$s .carousel-item {
  height: 390px;
}
#%1$s .carousel-item a {
  display: block;
  height: 100%%;
}
#%1$s .carousel-img {
  width: 100%%;
  height: 100%%;
  object-fit: cover;
  display: block;
}
#%1$s-footer {
  padding: 12px 8px 4px;
}
.%1$s-cap {
  display: none;
  text-align: center;
  font-size: 0.875rem;
  font-weight: 500;
  color: #374151;
  line-height: 1.6;
  margin: 0 0 10px;
}
.%1$s-cap.active {
  display: block;
}
#%1$s-dots {
  display: flex;
  justify-content: center;
  gap: 8px;
  padding: 0;
  margin: 0;
}
.%1$s-dot {
  width: 7px;
  height: 7px;
  border-radius: 50%%;
  border: none;
  background: #d1d5db;
  padding: 0;
  cursor: pointer;
  transition: background-color 0.25s ease, transform 0.2s ease;
}
.%1$s-dot.active {
  background: #4b5563;
  transform: scale(1.4);
}
#%1$s .carousel-control-prev,
#%1$s .carousel-control-next {
  width: 36px;
  height: 36px;
  top: 50%%;
  bottom: auto;
  transform: translateY(-50%%);
  background: rgba(255, 255, 255, 0.85);
  border-radius: 50%%;
  box-shadow: 0 1px 6px rgba(0, 0, 0, 0.15);
  opacity: 0.8;
  transition: opacity 0.2s ease;
}
#%1$s .carousel-control-prev {
  left: -52px;
}
#%1$s .carousel-control-next {
  right: -52px;
}
#%1$s .carousel-control-prev-icon,
#%1$s .carousel-control-next-icon {
  width: 16px;
  height: 16px;
  filter: brightness(0);
}
#%1$s-card:hover .carousel-control-prev,
#%1$s-card:hover .carousel-control-next {
  opacity: 1;
}
@media (max-width: 767px) {
  #%1$s .carousel-control-prev,
  #%1$s .carousel-control-next {
    opacity: 0.6;
  }
}
",
    id
  )))

  js <- tags$script(HTML(sprintf(
    "
(function () {
  function init() {
    var carousel = document.getElementById('%1$s');
    if (!carousel) return;
    carousel.addEventListener('slide.bs.carousel', function (e) {
      var card = document.getElementById('%1$s-card');
      card.querySelectorAll('.%1$s-cap').forEach(function (el, i) {
        el.classList.toggle('active', i === e.to);
      });
      card.querySelectorAll('.%1$s-dot').forEach(function (el, i) {
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
      class = paste0(id, "-cap", if (i == 1) " active" else ""),
      items[[i]]$caption
    )
  }))

  dots <- tagList(lapply(seq_along(items), function(i) {
    btn <- tags$button(
      class = paste0(id, "-dot", if (i == 1) " active" else ""),
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

  div(
    id = paste0(id, "-card"),
    css,
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
      id = paste0(id, "-footer"),
      captions,
      div(id = paste0(id, "-dots"), dots)
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
