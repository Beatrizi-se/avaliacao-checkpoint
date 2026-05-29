import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/banner_hero_widget.dart';
import '../widgets/product_card_widget.dart';
import '../widgets/subscription_section_widget.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';
import '../services/auth_service.dart';
import '../models/product.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  _InitialScreenState createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    // Busca os produtos ao iniciar a tela
    _productsFuture = _apiService.getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.menu_outlined, size: 32, color: Color(0xFF0D0D2B)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outlined, size: 32, color: Color(0xFF0D0D2B)),
            onPressed: () {
              if (AuthService().isAuthenticated) {
                // Diálogo de logout se o usuário estiver autenticado
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Sair'),
                    content: const Text('Deseja sair da sua conta?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          AuthService().logout();
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: const Text('Sair'),
                      ),
                    ],
                  ),
                );
              } else {
                // Redireciona para login se não estiver autenticado
                Navigator.pushNamed(context, '/login');
              }
            },
          ),
          const SizedBox(width: 10),
          // Botão do carrinho com contador reativo
          ListenableBuilder(
            listenable: CartService(),
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined, size: 32, color: Color(0xFF0D0D2B)),
                    onPressed: () => Navigator.pushNamed(context, '/cart'),
                  ),
                  if (CartService().items.isNotEmpty)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8A2BE2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${CartService().items.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 20),
        ],
        title: Image.asset(
          'assets/logo_usedev.png',
          height: 40,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const BannerHeroWidget(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  Text(
                    'Promos Especiais',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.orbitron(
                      fontSize: 31,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0D0D2B),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Lista dinâmica de produtos vinda da API
                  FutureBuilder<List<Product>>(
                    future: _productsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: Color(0xFF8A2BE2)),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Erro ao carregar produtos',
                            style: GoogleFonts.poppins(color: Colors.red),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('Nenhum produto encontrado'));
                      }

                      final products = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: products.length > 6 ? 6 : products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return ProductCardWidget(
                            product: product,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/product-detail',
                                arguments: product,
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const SubscriptionSectionWidget(),
          ],
        ),
      ),
    );
  }
}
