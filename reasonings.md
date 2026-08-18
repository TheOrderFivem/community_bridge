> **Note:** This is **not intended to be a mergable PR as-is**. This is primarily a conversation starter to determine whether this direction is a good fit for the organization and the future of Community Bridge, or whether these changes would be better suited as a separate fork.

I think Community Bridge has been a huge benefit to the FiveM ecosystem and has helped a lot of creators support different frameworks without having to reinvent the same integrations over and over.

That said, I think the scope of the project has gradually become too broad. A number of the library modules are now duplicating functionality that already exists in `ox_lib`, which is already a required dependency of Community Bridge.

Because of that, I don't think we should maintain abstractions for functionality that can already be handled directly by `ox_lib`. It adds additional code, maintenance, and surface area without providing much benefit.

This PR removes the following `lib` modules:

* `anim` — already provided by `ox_lib`
* `callback` — can be replaced with `ox_lib` callbacks
* `markers` — already handled by `ox_lib`
* `raycast` — already handled by `ox_lib` and relatively niche
* `scaleform` — already handled by `ox_lib`
* `shells` — should be owned by the resource that needs them rather than the bridge
* `sql` — effectively another abstraction over `oxmysql` without providing ORM-level functionality
* `vehicles` — unnecessary given existing `ox_lib` functionality
* `cutscenes` — extremely niche and doesn't justify being maintained as part of the bridge
* `client_entity_actions_ext` — while this could be a nice module, it leans into the idea of making this a library + bridge and gives the project too wide of a scope

I've also removed the `zones` and `locale` modules.

PolyZone has been around for a long time and was a perfectly reasonable solution when there weren't many alternatives. However, it hasn't received a meaningful update in years, and I don't think we should continue building abstractions around it when `ox_lib` already provides a modern zone implementation.

Since `ox_lib` is already a required dependency of Community Bridge, I'd rather enforce the use of the better-supported implementation than continue wrapping an older solution simply for compatibility.

If someone eventually develops a zone library that is genuinely better or provides functionality that `ox_lib` doesn't, I'm completely open to revisiting this decision. But right now, I don't think there's a strong reason to maintain a bridge layer around PolyZone.

As for locales, `ox_lib` already does a really great job with locales, and we should be utilizing this as well.

# Footnote

The goal here isn't to remove functionality for the sake of removing it. It's to establish a much narrower scope for Community Bridge and avoid turning it into a general-purpose library.

I'd rather see the bridge focus its maintenance and development effort on framework/resource compatibility — the part that actually benefits from having a bridge — while leaving general-purpose functionality to libraries that already specialize in it.

Again, **this PR is not meant to be merged immediately**. I'd like to use it as a starting point for discussion about what Community Bridge should actually be responsible for going forward. If this direction doesn't fit the organization's goals for the project, that's completely fine; I'd rather establish that now and potentially pursue these changes as a separate fork than continue moving the project in a direction that doesn't align with its intended purpose.

If there's a legitimate use case for any of these modules that I'm overlooking, I'm absolutely open to discussing it. The main thing I'm trying to avoid is maintaining duplicate abstractions simply because they exist.


p.s. no Ai use in the my removals / additions as code, but im a stupid dude and english isnt my first language (moron is) so i used Ai to pretty up the words here