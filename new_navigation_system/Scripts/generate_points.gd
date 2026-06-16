@tool
extends Node3D
class_name generate_navigation_points

class NavigationPoint:
    var index: int
    var position: Vector3
    var neighbors: Array
    

var navigation_points: Array[NavigationPoint] = []
var array_of_debug_spheres = []
@export var point_spacing: float = 2.0


@onready var box := Vector2(16, 16)

@export var navigation_mesh: NavigationRegion3D
@export_tool_button("Bake points")

var points_bake_btn = bake_points

func bake_points():
    if navigation_mesh == null:
        print("Navigation mesh is not assigned.")
        return
    
    for sphere in array_of_debug_spheres:
        if sphere and sphere.is_inside_tree():
            sphere.queue_free()

    array_of_debug_spheres.clear()
    navigation_points.clear()

    _flatten()
    print("baked points: %d" % navigation_points.size())

    for point in navigation_points:
        spawn_sphere_at_position(point.position)
    
func spawn_sphere_at_position(spawn_pos: Vector3):
    var sphere = MeshInstance3D.new()
    var sphere_mesh = SphereMesh.new()

    add_child(sphere)
    sphere_mesh.radius = 0.5
    sphere_mesh.height = 1.0
    sphere.mesh = sphere_mesh
    sphere.global_position = spawn_pos
    array_of_debug_spheres.append(sphere)

func _flatten():
    var navmesh: NavigationMesh = navigation_mesh.navigation_mesh

    if navmesh == null:
        return

    var vertices = navmesh.get_vertices()

    navigation_points.clear()

    for poly_index in navmesh.get_polygon_count():
        var polygon = navmesh.get_polygon(poly_index)

        if polygon.size() < 3:
            continue

        # Collect polygon vertices
        var poly_vertices: Array[Vector3] = []

        for vertex_index in polygon:
            poly_vertices.append(vertices[vertex_index])

        var origin = poly_vertices[0]

        # Build local coordinate system
        var normal = (
            poly_vertices[1] - origin
        ).cross(
            poly_vertices[2] - origin
        ).normalized()

        var tangent = normal.cross(Vector3.UP)

        if tangent.length_squared() < 0.0001:
            tangent = normal.cross(Vector3.RIGHT)

        tangent = tangent.normalized()

        var bitangent = normal.cross(tangent).normalized()

        # Convert polygon to 2D
        var poly_2d: Array[Vector2] = []

        for vertex in poly_vertices:
            var relative = vertex - origin

            poly_2d.append(
                Vector2(
                    relative.dot(tangent),
                    relative.dot(bitangent)
                )
            )

        # Find polygon bounds
        var min_x := INF
        var max_x := -INF
        var min_y := INF
        var max_y := -INF

        for p in poly_2d:
            min_x = min(min_x, p.x)
            max_x = max(max_x, p.x)

            min_y = min(min_y, p.y)
            max_y = max(max_y, p.y)

        var start_x = int(floor(min_x / point_spacing))
        var end_x = int(ceil(max_x / point_spacing))

        var start_y = int(floor(min_y / point_spacing))
        var end_y = int(ceil(max_y / point_spacing))

        # Generate points
        for x in range(start_x, end_x + 1):
            for y in range(start_y, end_y + 1):
                var candidate = Vector2(
                    (x + 0.5) * point_spacing,
                    (y + 0.5) * point_spacing
                )

                if not Geometry2D.is_point_in_polygon(candidate, poly_2d):
                    continue

                var point_3d = (
                    origin
                    + tangent * candidate.x
                    + bitangent * candidate.y
                )

                # Avoid duplicate points between adjacent polygons
                var is_duplicate := false

                for existing_point in navigation_points:
                    if existing_point.position.distance_squared_to(point_3d) < 0.01:
                        is_duplicate = true
                        break

                if is_duplicate:
                    continue

                var nav_point = NavigationPoint.new()
                nav_point.index = navigation_points.size()
                nav_point.position = point_3d
                nav_point.neighbors = []

                navigation_points.append(nav_point)

func generate_points():
    var navmesh: NavigationMesh = navigation_mesh.navigation_mesh
    var vertices = navmesh.get_vertices()

    navigation_points.clear()

    for i in vertices.size():
        var navigation_point = NavigationPoint.new()
        navigation_point.index = i
        navigation_point.position = vertices[i]
        navigation_point.neighbors = []

        navigation_points.append(navigation_point)


    for poly_index in navmesh.get_polygon_count():
        var polygon = navmesh.get_polygon(poly_index)

        for i in polygon.size():
            var current_index = polygon[i]

            var prev_index = polygon[(i - 1 + polygon.size()) % polygon.size()]
            var next_index = polygon[(i + 1) % polygon.size()]

            var current_point = navigation_points[current_index]

            if !current_point.neighbors.has(prev_index):
                current_point.neighbors.append(prev_index)

            if !current_point.neighbors.has(next_index):
                current_point.neighbors.append(next_index)
    
    subdivide_long_connections()

func subdivide_long_connections():
    var processed_edges := {}

    for point in navigation_points:
        var original_neighbors = point.neighbors.duplicate()

        for neighbor_index in original_neighbors:
            var edge_key = _get_edge_key(point.index, neighbor_index)

            # Don't process the same edge twice
            if processed_edges.has(edge_key):
                continue

            processed_edges[edge_key] = true

            var neighbor = navigation_points[neighbor_index]

            var distance = point.position.distance_to(neighbor.position)

            if distance <= point_spacing:
                continue

            subdivide_connection(point, neighbor, distance)


func _get_edge_key(a: int, b: int) -> String:
    return "%d_%d" % [min(a, b), max(a, b)]


func subdivide_connection(a: NavigationPoint, b: NavigationPoint, distance: float):
    # Remove original connection
    a.neighbors.erase(b.index)
    b.neighbors.erase(a.index)

    var segment_count = ceil(distance / point_spacing)
    var previous_index = a.index

    for i in range(1, segment_count):
        var t = float(i) / segment_count

        var new_point = NavigationPoint.new()
        new_point.index = navigation_points.size()
        new_point.position = a.position.lerp(b.position, t)
        new_point.neighbors = []

        navigation_points.append(new_point)

        navigation_points[previous_index].neighbors.append(new_point.index)
        new_point.neighbors.append(previous_index)

        previous_index = new_point.index

    navigation_points[previous_index].neighbors.append(b.index)
    b.neighbors.append(previous_index)