library(showtext)
library(ggplot2)
library(here)
library(magick)

font_add_google("Libre Baskerville", "font")
showtext_auto()

p <- ggplot() + 
  annotate("text", x = 0.5, y = 0.5, label = "Y.Abe", size = 10, family = "font", fontface = "bold", color = "white") + 
  theme_void()

ggsave(here("figure/logo.png"), plot = p, bg = "transparent", width = 10, height = 10, dpi = 300)

img <- image_read(here("figure/logo.png")) |> 
  image_trim()

image_write(img, path = here("figure/logo.png"))