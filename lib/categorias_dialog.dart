import 'package:control_gastos_carros/modelos/categorias.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/categorias_bloc_db.dart';


class CategoriasDialog extends StatelessWidget {
  const CategoriasDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: BlocBuilder<CategoriasBloc, CategoriasEstado>(
          builder: (context, state) {
            List<Categoria> categorias = state.categorias;
  
            return SingleChildScrollView(
              child: Column(
                children: [
                  for (Categoria categoria in categorias)
                    ListTile(
                      title: Text(categoria.nombre),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          // Handle delete category action
                          context.read<CategoriasBloc>().add(
                                DeleteCategoria(
                                  categoria: categoria,
                                ),
                              );
                          Navigator.of(context).pop(); // Close the dialog
                        },
                      ),
                    ),
                ],
              ),
            );
                    },
        ),
    );
  }

  static void mostrarDialogoVerCategorias(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const CategoriasDialog();
      },
    );
  }
}
