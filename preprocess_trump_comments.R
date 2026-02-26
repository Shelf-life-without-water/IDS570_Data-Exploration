
packages <- c("readr", "dplyr", "stringr", "tidytext")
to_install <- packages[!packages %in% rownames(installed.packages())]
if(length(to_install) > 0) install.packages(to_install)

df <- readr::read_csv(
  "~/Downloads/youtube_comments_donald_trump_last_year.csv",
  show_col_types = FALSE
)

df_clean <- df |>
  dplyr::mutate(
    clean_text = text |>
      as.character() |>
      stringr::str_to_lower() |>
      stringr::str_replace_all("http\\S+", "") |>
      stringr::str_replace_all("[^a-z\\s]", " ") |>
      stringr::str_squish()
  ) |>
  dplyr::distinct(comment_id, .keep_all = TRUE)

data("stop_words")

tidy_words <- df_clean |>
  dplyr::select(comment_id, video_id, clean_text) |>
  tidytext::unnest_tokens(word, clean_text) |>
  dplyr::anti_join(stop_words, by = "word")

word_freq <- tidy_words |>
  dplyr::count(word, sort = TRUE)

print(head(word_freq, 20))

tfidf_data <- tidy_words |>
  dplyr::count(video_id, word) |>
  tidytext::bind_tf_idf(word, video_id, n) |>
  dplyr::arrange(desc(tf_idf))

print(head(tfidf_data, 20))

readr::write_csv(
  df_clean,
  "~/Downloads/youtube_comments_clean_r.csv"
)
