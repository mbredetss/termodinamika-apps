import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'materi_data.dart';

class MateriScreen extends StatelessWidget {
  const MateriScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Materi Termodinamika'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Markdown(
          data: markdownContent,
          selectable: true,
          styleSheet: MarkdownStyleSheet(
            h1: const TextStyle(
              fontFamily: 'StackSansText',
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
            h2: const TextStyle(
              fontFamily: 'StackSansText',
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
            p: const TextStyle(
              fontFamily: 'StackSansText',
              fontSize: 20,
              height: 1.6,
            ),
            listBullet: const TextStyle(
              fontFamily: 'StackSansText',
              fontSize: 20,
            ),
            code: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 18,
              backgroundColor: Colors.grey,
              color: Colors.white,
            ),
          ),
          imageBuilder: (Uri uri, String? title, String? altText) {
            // Check if the URI is a relative path that should point to assets
            if (uri.path.contains('Aspose.Words')) {
              // Map the image names to actual asset paths
              String assetPath = 'assets/images/${uri.path.split('/').last}';
              return Container(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Center(
                      child: Image.asset(
                        assetPath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.image_not_supported,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Image: ${uri.path.split('/').last}',
                                  style: const TextStyle(
                                    fontFamily: 'StackSansText',
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  '(Place image in assets/images/)',
                                  style: const TextStyle(
                                    fontFamily: 'StackSansText',
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    if (altText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          altText,
                          style: const TextStyle(
                            fontFamily: 'StackSansText',
                            fontSize: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            } else {
              // For other image URLs, use standard network loading
              return Container(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          uri.toString(),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 60,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    if (altText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          altText,
                          style: const TextStyle(
                            fontFamily: 'StackSansText',
                            fontSize: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }
          },
        ),
      ),


    );
  }
}