# Get Your Machine Ready

You need a Markdown reader or the Astrona reading interface. A browser can display the repository pages. The course uses Mermaid diagrams, a text format that the reading interface turns into drawings. If your reader does not display a diagram, the surrounding prose still explains its mechanism.

Reading needs nothing more. The playgrounds and labs run a local Kubernetes cluster, so for those you need the Astrona command-line tool (`astrona`), a container engine such as Docker or Podman with about 2 GiB of free memory, and `kubectl`. Check the setup with `astrona check`. Start a playground with `astrona run`, grade a lab with `astrona submit`, and remove the environment with `astrona destroy`.

Use a notebook to record unfamiliar terms and your reasoning for each practice answer. When a page is missing, check that you are viewing the content branch or published revision that contains this draft. If a diagram or reading fails to load, record the page title and the visible error when reporting the issue.
