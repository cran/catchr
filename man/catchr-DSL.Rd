% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/help-docs.R
\name{catchr-DSL}
\alias{catchr-DSL}
\alias{language-of-catchr}
\alias{reserved-terms}
\alias{masking}
\alias{tomessage}
\alias{towarning}
\alias{toerror}
\alias{beep}
\alias{display}
\alias{muffle}
\alias{exit}
\alias{raise}
\title{The language of catchr}
\description{
catchr implements a small but helpful "domain-specific language" (DSL) to make building condition-handling functions simpler to read and type. Essentially, catchr reserves special 'terms' that mean something different than they do in the rest of R. When given as part of the input for a catchr plan, these terms will be substituted for special catchr functions used to handle conditions.

These special terms can be inputted as strings (e.g., \code{warning = list('collect', 'muffle')}) or as unquoted terms (e.g., \code{warning = c(collect, muffle)}); catchr internally converts the unquoted terms to strings regardless, but being able to input them unquoted saves keystrokes and can highlight their special meanings for code readability.
}
\section{Special reserved terms}{


The following are the special terms and what they do. Note that there are also some \link[=reserved-conditions]{special condition names}, but those are different from the following.
\itemize{
\item \strong{\code{tomessage}}, \strong{\code{towarning}}, \strong{\code{toerror}}: these terms will become functions that will convert captured conditions into a message, warning, or error, respectively, and raise them. The original classes of the condition will be lost.
\item \strong{\code{beep}}: if the \link[beepr:beepr-package]{beepr} package is installed, this will play a sound via \code{\link[beepr:beepr]{beepr::beep}}.
\item \strong{\code{display}}: the purpose of this term is to immediately display information about the captured condition on the output terminal without raising additional conditions (as would be done with \code{tomessage}). Currently, it attempts to display this information with bold, turquoise-blue text if the \link[crayon:crayon]{crayon} package is installed. In future versions of catchr, this default styling (and other display options) may be able to be changed by the user.
\item \strong{\code{muffle}}: this term will be substituted for a function that 'muffles' (i.e., 'suppresses', 'catches', 'hides'---whatever you want to call it) the captured condition, preventing it from being raised to higher levels or subsequent plans. Anything in a plan \emph{after} \code{muffle} will be ignored, so put it last. \cr
The function \code{muffle} is built on, \code{\link[=first_muffle_restart]{first_muffle_restart()}}, searches for the first available \link[base:conditions]{restart} with \code{"muffle"} in its name (the two typical ones are \code{"muffleMessage"} and \code{"muffleWarning"}) and calls \code{invokeRestart} with it. If the captured condition is an error, which can't be muffled, it will exit the evaluation and give \code{NULL} for the returned value of the evaluated expression.
\item \strong{\code{exit}}: when encountered, this will exit the evaluation of the expression immediately and by default muffle the captured condition (use \code{raise} in the plan if to ensure this doesn't happen). Any instructions after \code{exit} in the input will be ignored, so put it last.
\item \strong{\code{collect}}: this term will store the captured conditions and append them to the output of the evaluated expression. See the \link[=collecting-conditions]{collecting conditions} help topic for a full explanation.
\item \strong{\code{raise}}: this term will raise the captured condition "as is". The only \emph{real} use for this term is when you want to use \code{exit} to stop the evaluation, but to still raise the condition past that as well (in which case, put \code{raise} in the plan before \code{exit}). The behavior of this raising might be slightly unpredictable for very odd edge-cases (e.g., if a condition were both a warning \emph{and} an error).
}
}

\section{Masking}{


catchr will turn unquoted special terms into functions, but what happens if these unquoted terms are identical to variables previously declared?

If \code{muffle} is the name of a user-defined function, e.g., \code{muffle <- function(x) print("Wooo!")}, in normal R we would expect \code{warning = muffle} to make \code{function(x) print("Wooo!")} the warning handler.

\emph{However}, catchr's DSL "masks" any symbol that matches one of its reserved terms, and when it evaluates these symbols, they are converted into strings. For the most part, catchr will warn you when this happens.

\strong{Importantly}, catchr does \emph{not} mask reserved terms when:
\itemize{
\item the reserved names are being used as calls, e.g., \code{warning = collect(foo)}. In these cases, it will attempt to use a previously defined function \code{collect} on \code{foo}, and will attempt to use whatever that evaluates to. The reserved terms are all strings/unquoted bare symbols, so it is never a problem anyway.
\item the input specifically references a namespace/package, such as \code{warning = dplyr::collect}. When the symbol of a special terms is preceded by \code{::} or \code{:::}, it will be seen as the function of that package, and not as the special term \code{collect}.
\item the reserved terms are used inside a previously defined function. For example, if the user had defined \code{muffle <- function(x) print("not special")}, and \code{fn <- function(x) muffle}, using the argument \code{warning = fn()} would not use the special term of \code{muffle}.
}
}

